require 'rake/clean'
require 'pathname'

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
OUT_DIR = PROJECT_ROOT.join("out").freeze

directory OUT_DIR.join("doc")

CLASSES = Dir[PROJECT_ROOT.join("tex","*", "*.cls")].freeze
PACKAGES = Dir[PROJECT_ROOT.join("text", "**", "*.sty")].freeze

Dir[PROJECT_ROOT.join("doc","**","Readme.tex")].each do |file|
  out_path = OUT_DIR.join(Pathname(file) \
                    .expand_path.relative_path_from(PROJECT_ROOT)) \
                    .sub_ext(".pdf")

  directory out_path.dirname.to_s

  file out_path => [out_path.dirname.to_s, file.to_s] + CLASSES + PACKAGES do 
    build file, out_path
  end

  task :doc => [out_path.to_s]
end

desc "Generates the documentation"
task :doc => CLASSES + PACKAGES

task :test do 
  LatexTesting.scan PROJECT_ROOT.join("test")
  LatexTesting.run out_folder: OUT_DIR
end