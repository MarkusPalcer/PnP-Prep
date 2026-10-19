require "fileutils"
require "tmpdir"
require "pathname"

module LatexTesting
  GREEN = "\e[32m"
  RED   = "\e[31m"
  RESET = "\e[0m"

  PROJECT_ROOT = Pathname(__dir__).join("..").realpath.freeze
  OUT_DIR = PROJECT_ROOT.join("out").freeze


  # Binding for a *tests.rb / *test.rb file.
  class TestFile
    attr_reader :filename

    def initialize(filename)
      @filename = File.expand_path(filename)
      @suites = {}

      # Tests defined directly in the file belong to this suite.
      @file_suite = TestSuite.new(File.basename(@filename, ".rb"), output_dir: output_base, input_dir: File.dirname(@filename))
    end

    def testsuite(name, &block)
      suite = @suites[name.to_s] ||= TestSuite.new(name, output_dir: File.join(output_base, name.to_s), input_dir: File.dirname(@filename))

      suite.instance_eval(&block) if block
      suite
    end

    def test(name, &block)
      @file_suite.test(name, &block)
    end

    def execute(options = {})
      puts @filename
      @file_suite.execute(options)
      @suites.each_value { |suite| suite.execute(options) }
    end

    private

    def output_base
      relative_path = Pathname.new(@filename)
        .relative_path_from(PROJECT_ROOT)
        .to_s

      # Preserve the test file's directory structure and filename.
      relative_path = relative_path.sub(/\.rb\z/, "")
      File.join(OUT_DIR, relative_path)
    end
  end

  # Binding for a testsuite block.
  class TestSuite
    attr_reader :name

    def initialize(name, output_dir:, input_dir:)
      @name = name.to_s
      @output_dir = output_dir
      @input_dir = input_dir
      @tests = []
    end

    def test(name, &block)
      test = Test.new(
        name,
        output_dir: File.join(@output_dir),
        input_dir: @input_dir
      )

      test.instance_eval(&block) if block
      @tests << test
      test
    end

    def execute(options = {})
      return if @tests.empty?

      puts "  #{@name}"
      @tests.each { |test| test.execute(options) }
    end
  end

  # Binding for a test block.
  class Test
    attr_reader :name

    def initialize(name, output_dir:, input_dir:)
      @name = name.to_s
      @output_dir = output_dir
      @input_dir = input_dir
      @file = nil
      @expect_failure = false
      @log_assertions = []
    end

    def file(value)
      @file = value
    end
    
    def expect_failure
      @expect_failure = true
    end

    def requires_log(snippet)
      @log_assertions << snippet
    end

    def execute(options = {})
      print "    #{@name} - "
      begin
        unless @file
          raise "no .tex file given"
        end

        file = Pathname.new(@input_dir).join(@file).to_s

        unless File.file? file
          raise "#{@file} not found"
        end

        Dir.mktmpdir("latex-testing-") do |temp_dir|
          result = run temp_dir
          raise "Build did not pass" if !result && !@expect_failure
          raise "Build passed unexpectedly" if result && @expect_failure

          test_log temp_dir
        end

        puts "#{GREEN}PASS#{RESET}"
        true
      rescue StandardError => e
        puts "#{RED}FAIL#{RESET} - #{e.message}"
        false
      end
    end

    private

    def temp_file(temp_dir, extension)
      file = Pathname.new(@file)
      File.join(temp_dir, "#{file.basename.sub_ext(extension)}")
    end

    def test_log(temp_dir)
      temp_log = temp_file(temp_dir, ".log")

      raise "No log file produced by LaTeX build" unless File.file? temp_log

      log = File.read(temp_log)

      @log_assertions.each do |assertion|
        raise "Log is missing #{RED}#{assertion}#{RESET}" unless log.include? assertion
      end
    end

    def run(temp_dir)
      file = Pathname.new(@input_dir).join(@file).to_s
      temp_dir = Pathname.new(temp_dir)
      FileUtils.mkdir_p(@output_dir)

      temp_pdf = temp_file(temp_dir, ".pdf")
      temp_log = temp_file(temp_dir, ".log")

      begin
        # Assumes an existing build(source, output_pdf) helper.
        raise "Build failed" unless build_raw file, temp_dir

        unless File.file?(temp_pdf)
          raise "Build completed without producing a PDF"
        end

        FileUtils.cp(temp_pdf, File.join(@output_dir, "#{@name}.pdf"))
        true
      rescue StandardError => e
        log = if File.file?(temp_log)
                File.read(temp_log)
              else
                "#{e.class}: #{e.message}\n#{e.backtrace&.join("\n")}"
              end

        File.write(File.join(@output_dir, "#{@name}.log"), log)

        false
      end
    end
  end

  @files = {}

  class << self
    def parse_file(filename)
      filename = File.expand_path(filename)

      # Reuse an already parsed file.
      return @files[filename] if @files.key?(filename)

      test_file = TestFile.new(filename)

      # Register before evaluating to avoid duplicate instances
      # if loading indirectly refers to this file again.
      @files[filename] = test_file

      source = File.read(filename)
      test_file.instance_eval(source, filename, 1)

      test_file
    rescue StandardError
      @files.delete(filename) if filename
      raise
    end

    def scan(base_dir)
        base_dir = base_dir.to_s

        patterns = %w[
            **/*tests.rb
            **/*test.rb
            **/test.rb
            **/tests.rb
        ]

        files = patterns.flat_map do |pattern|
            Dir.glob(File.join(base_dir, pattern))
        end

        files.uniq.sort.each do |filename|
            parse_file(filename)
        end
    end

    def run(options = {})
      @files.each_value do |test_file|
        test_file.execute(options)
      end
    end
  end
end
