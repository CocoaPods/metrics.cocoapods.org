source 'https://rubygems.org'
ruby '2.1.3'

gem 'activesupport'
# gem 'cocoapods-core' #, :git => 'https://github.com/CocoaPods/Core.git'
gem 'i18n'
gem 'json', '~> 1.8'
# gem 'nap', :git => 'https://github.com/alloy/nap.git', :branch => 'error'
gem 'pg'
gem 'sequel'
gem 'sinatra'
gem 'slim', '< 2.0'
gem 'sass'

# API libraries.
#
gem 'github_api', '~> 0.12.3'

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
  gem 'mocha-on-bacon'
  gem 'nokogiri'
  gem 'prettybacon'
  gem 'rack-test'
  gem 'rubocop'
  gem 'webmock'
end
