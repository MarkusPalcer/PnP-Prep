# frozen_string_literal: true

require 'rake/clean'
require 'pathname'
require 'bundler/setup'
require 'latextesting'

CLEAN.include('**/*.aux',
              '**/*.log',
              '**/*.out',
              '**/*.toc',
              '**/*.synctex.gz',
              '**/*.fls',
              '**/*.fdb_latexmk',
              '**/*.pdf',
              '**/*.dvi',
              '**/*.toc')

PROJECT_ROOT = Pathname(__dir__).realpath.freeze
OUT_DIR = PROJECT_ROOT.join('out').freeze
TEST_OPTIONS = { out_folder: OUT_DIR }.tap do |options|
  options[:user_interaction] = true if ENV.key?('MANUAL_TESTS')
end.freeze

directory OUT_DIR.join('doc')

CLASSES = Dir[PROJECT_ROOT.join('tex', '*', '*.cls')].freeze
PACKAGES = Dir[PROJECT_ROOT.join('text', '**', '*.sty')].freeze

Dir[PROJECT_ROOT.join('doc', '**', 'Readme.tex')].each do |file|
  out_path = OUT_DIR.join(Pathname(file) \
                    .expand_path.relative_path_from(PROJECT_ROOT)) \
                    .sub_ext('.pdf')

  directory out_path.dirname.to_s

  file out_path => [out_path.dirname.to_s, file.to_s] + CLASSES + PACKAGES do
    build file, out_path
  end

  task doc: [out_path.to_s]
end

desc 'Generates the documentation'
task doc: CLASSES + PACKAGES

desc 'Runs all tests'
task :test do
  LatexTesting.run(TEST_OPTIONS)
end

task_name_for = lambda do |name, used_names|
  base = name.to_s.downcase.gsub(/[^a-z0-9_-]+/, '_').gsub(/\A[-_]+|[-_]+\z/, '')
  base = 'unnamed' if base.empty?

  candidate = base
  suffix = 2
  while used_names.key?(candidate)
    candidate = "#{base}_#{suffix}"
    suffix += 1
  end
  used_names[candidate] = true
  candidate
end

test_suites = LatexTesting.scan(PROJECT_ROOT.join('test'))

namespace :test do
  used_suite_names = {}
  test_suites.each do |suite|
    suite_task_name = task_name_for.call(suite.name, used_suite_names)

    desc "Runs the #{suite.name} test suite"
    task suite_task_name do
      LatexTesting.run(TEST_OPTIONS, suite: suite)
    end

    namespace suite_task_name do
      used_test_names = {}
      suite.tests.each do |test_case|
        test_task_name = task_name_for.call(test_case.name, used_test_names)

        desc "Runs the #{test_case.name} test"
        task test_task_name do
          LatexTesting.run(TEST_OPTIONS, test: test_case)
        end
      end
    end
  end
end
