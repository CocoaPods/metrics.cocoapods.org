source 'https://rubygems.org'
ruby File.read(File.join(__dir__, '.ruby-version')).strip

gem 'activesupport'
# gem 'cocoapods-core' #, :git => 'https://github.com/CocoaPods/Core.git'
gem 'i18n'
gem 'nap'
gem 'pg'
gem 'sequel'
gem 'sinatra'
gem 'sass'

# API libraries.
#
gem 'github_api'

group :rake do
  gem 'rake'
  gem 'terminal-table'
end

group :development do
  gem 'kicker'
  gem 'sinatra-contrib'
end

group :development, :production do
  gem 'foreman'
  gem 'thin'
end

group :test do
  gem 'bacon'
  gem 'mocha', '~> 1.1.0'
  gem 'mocha-on-bacon'
  gem 'nokogiri'
  gem 'prettybacon'
  gem 'rack-test'
  gem 'rubocop'
  gem 'webmock'
end
