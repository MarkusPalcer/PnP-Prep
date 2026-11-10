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
    # Absolute path of the Ruby test-definition file.
    attr_reader :filename

    # Creates a definition context for a Ruby test file.
    #
    # @param filename [String] path to a `tests.rb` or `test.rb` file
    def initialize(filename)
      @filename = File.expand_path(filename)
      @suites = {}

      # Tests defined directly in the file belong to this suite.
      @file_suite = TestSuite.new(File.basename(@filename, ".rb"), output_dir: output_base, input_dir: File.dirname(@filename))
    end

    # Defines or reopens a named suite in this file.
    # The block is evaluated with the suite as `self`.
    #
    # @param name [String] suite label
    # @yield defines tests in the suite
    # @return [TestSuite] the named suite
    def testsuite(name, &block)
      raise "test suite defined without data" unless block_given?

      suite = @suites[name.to_s] ||= TestSuite.new(name, output_dir: File.join(output_base, name.to_s), input_dir: File.dirname(@filename))

      suite.instance_eval(&block) if block
      suite
    end

    # Defines a test in this file's implicit, file-level suite.
    # The block is evaluated with the test as `self`.
    #
    # @param name [String] test label
    # @yield configures the test
    # @return [Test] the new test
    def test(name, &block)
      @file_suite.test(name, &block)
    end

    # Runs the file-level suite followed by each named suite.
    #
    # @param options [Hash] options forwarded to suites
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
    # Human-readable suite label.
    attr_reader :name

    # Creates a suite bound to its output and fixture directories.
    #
    # @param name [String] suite label
    # @param output_dir [String] directory for generated test artifacts
    # @param input_dir [String] directory containing LaTeX fixtures
    def initialize(name, output_dir:, input_dir:)
      @name = name.to_s
      @output_dir = output_dir
      @input_dir = input_dir
      @tests = []
    end

    # Defines a test and evaluates its configuration block in the test context.
    #
    # @param name [String] test label
    # @yield configures the test
    # @return [Test] the new test
    def test(name, &block)
      raise "test defined without data" unless block_given?

      test = Test.new(
        name,
        output_dir: File.join(@output_dir),
        input_dir: @input_dir
      )

      test.instance_eval(&block) if block
      @tests << test
      test
    end

    # Executes every test in this suite.
    #
    # @param options [Hash] options forwarded to tests
    def execute(options = {})
      return if @tests.empty?

      puts "  #{@name}"
      @tests.each { |test| test.execute(options) }
    end
  end

  # Binding for a test block.
  class Test
    # Human-readable test label.
    attr_reader :name

    # Creates a test definition.
    #
    # @param name [String] test label
    # @param output_dir [String] directory for generated test artifacts
    # @param input_dir [String] directory containing LaTeX fixtures
    def initialize(name, output_dir:, input_dir:)
      @name = name.to_s
      @output_dir = output_dir
      @input_dir = input_dir
      @file = nil
      @expect_failure = false
      @assertions = []
    end

    # Adds a named custom assertion to run after the fixture is built.
    # The block runs with an assertion execution context as `self`, which
    # provides `log` (the build log) and `fail(message)` for reporting failure.
    # Captured local variables remain available to the block.
    #
    # @param name [String, nil] label included in an assertion failure
    # @yield checks the build result
    # @return [Array<Assertion>] the assertions configured for this test
    #
    # @example Check for a message in the build log
    #   assert "Expected warning" do
    #     fail "Warning was not produced" unless log.include?("Expected warning")
    #   end
    def assert(name = nil, &block)
      raise "assertion called without code block" unless block_given?

      @assertions << Assertion.new(@file, name, block)
    end

    # Selects the LaTeX fixture for this test.
    #
    # @param value [String] fixture filename relative to the test definition
    #   file's directory
    # @return [String] the selected filename
    def file(value)
      @file = value
    end
    
    # Marks compilation failure as the expected outcome.
    # Use {#requires_log} or {#assert} to check why compilation failed.
    #
    # @return [Boolean] true
    def expect_failure
      @expect_failure = true
    end

    # Adds an assertion that the LaTeX log contains the given substring.
    #
    # @param snippet [String] text that must appear in the build log
    # @return [Array<Assertion>] the assertions configured for this test
    def requires_log(snippet)
      assert "Log contains '#{snippet}'" do 
        fail "Not found" unless log.include? snippet
      end
    end

    # Builds the selected fixture, checks the expected build outcome, then
    # executes its assertions. Reports failures and returns whether the test
    # passed.
    #
    # @param options [Hash] reserved options forwarded by the runner
    # @return [Boolean] whether the test passed
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

          @assertions.each do |assertion|
            assertion.execute temp_dir
          end
        end

        puts "#{GREEN}PASS#{RESET}"
        true
      rescue StandardError => e
        puts "#{RED}FAIL#{RESET}: #{e.message}"
        false
      end
    end

    private

    def temp_file(temp_dir, extension)
      file = Pathname.new(@file)
      File.join(temp_dir, "#{file.basename.sub_ext(extension)}")
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

  class Assertion 
    # Creates an assertion associated with a fixture and a block.
    #
    # @param file [String] fixture filename used to locate the build log
    # @param name [String, nil] failure label
    # @param block [Proc] assertion body
    def initialize(file, name, block)
      @file = file
      @name = name.to_s unless name.nil?
      @block = block 
    end

    # Evaluates the assertion body with an {Execution} object as `self`.
    #
    # @param temp_dir [String] directory containing the LaTeX build artifacts
    def execute(temp_dir)
      execution = Execution.new(temp_dir, @file)
      
      begin
        execution.instance_exec(&@block)
      rescue StandardError => e
        raise "#{@name}: #{e.message}"
      end
    end

    class Execution

      # Creates the context in which a custom assertion is evaluated.
      #
      # @param temp_dir [String] directory containing the LaTeX build artifacts
      # @param file [String] fixture filename used to locate its log
      def initialize(temp_dir, file)
        @temp_dir = temp_dir
        @file = file
        @log = nil
      end

      # Reads and caches the LaTeX log for the current fixture.
      #
      # @return [String] contents of the build log
      # @raise [RuntimeError] if the build did not produce a log file
      def log
        return @log unless @log.nil?

        temp_log = temp_file(".log")

        raise "No log file produced by LaTeX build" unless File.file? temp_log

        @log = File.read(temp_log)

        return @log 
      end

      # Returns the path to the PDF generated for the current fixture.
      #
      # @return [String] path to the generated PDF
      # @raise [RuntimeError] if the build did not produce a PDF file
      def pdf_path
        temp_pdf = temp_file(".pdf")
        raise "No PDF file produced by LaTeX build" unless File.file? temp_pdf

        temp_pdf
      end

      # Opens the generated PDF and evaluates the block with its reader API.
      # Assertion execution helpers remain available in the block.
      #
      # @yield checks the PDF using HexaPDF's document API
      # @raise [RuntimeError] if the block is missing or the PDF cannot be read
      def generated_pdf(&block)
        raise "generated_pdf called without code block" unless block_given?

        require "hexapdf"
        document = HexaPDF::Document.open(pdf_path)
        PDFExecution.new(self, document).instance_exec(&block)
      end

      # Fails the current assertion with the given message.
      #
      # @param message [String] explanation included in the test failure
      # @raise [RuntimeError] always
      def fail(message)
        raise message
      end

      private
        def temp_file(extension)
          file = Pathname.new(@file)
          File.join(@temp_dir, "#{file.basename.sub_ext(extension)}")
        end

      class PDFExecution
        def initialize(execution, document)
          @execution = execution
          @document = document
        end

        def method_missing(name, *arguments, **keywords, &block)
          target = @execution.respond_to?(name) ? @execution : @document
          target.public_send(name, *arguments, **keywords, &block)
        end

        def respond_to_missing?(name, include_private = false)
          @execution.respond_to?(name, include_private) ||
            @document.respond_to?(name, include_private) ||
            super
        end
      end
    end
  end

  @files = {}

  class << self
    # Loads and evaluates one test-definition file.
    # Repeated calls for the same expanded path return the cached definition.
    #
    # @param filename [String] path to a Ruby test-definition file
    # @return [TestFile] the parsed file definition
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

    # Recursively loads test-definition files under a directory.
    # Matching files are evaluated in sorted, de-duplicated order.
    #
    # @param base_dir [String, #to_s] directory to scan
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

    # Executes all test files previously loaded with {scan} or {parse_file}.
    #
    # @param options [Hash] options forwarded to test files
    def run(options = {})
      @files.each_value do |test_file|
        test_file.execute(options)
      end
    end
  end
end
