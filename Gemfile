source "https://rubygems.org"

gem "hexapdf"

group :development do
  gem "ruby-lsp", require: false
end

Dir.glob("gems/*/Gemfile").sort.each do |gemfile|
  eval_gemfile gemfile
end
