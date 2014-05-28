require 'bacon'
require 'pretty_bacon'

require 'rack/test'
require 'digest'

require 'mocha-on-bacon'
Mocha::Configuration.prevent(:stubbing_non_existent_method)

# require 'cocoapods-core'

ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../../', __FILE__)
require 'config/init'

$LOAD_PATH.unshift(ROOT, 'spec')
Dir.glob(File.join(ROOT, 'spec/spec_helper/**/*.rb')).each do |filename|
  require File.join('spec_helper', File.basename(filename, '.rb'))
end

class Bacon::Context
  def test_controller!(app)
    extend Rack::Test::Methods

    singleton_class.send(:define_method, :app) { app }
    singleton_class.send(:define_method, :response_doc) { Nokogiri::HTML(last_response.body) }
  end

  alias_method :run_requirement_before_sequel, :run_requirement
  def run_requirement(description, spec)
    TRUNK_APP_LOGGER.info('-' * description.size)
    TRUNK_APP_LOGGER.info(description)
    TRUNK_APP_LOGGER.info('-' * description.size)
    Sequel::Model.db.transaction(:rollback => :always) do
      run_requirement_before_sequel(description, spec)
    end
  end
end
module Kernel
  alias_method :describe_before_controller_tests, :describe

  def describe(*description, &block)
    if description.first.is_a?(Class) # && description.first.superclass.ancestors.include?(ParentController)
      klass = description.first
      # Configure controller test and always use HTTPS
      describe_before_controller_tests(*description) do
        test_controller!(klass)
        # before { header 'X-Forwarded-Proto', 'https' }
        instance_eval(&block)
      end
    else
      describe_before_controller_tests(*description, &block)
    end
  end
end

module Bacon
  module BacktraceFilter
    # Gray-out those backtrace lines that are usually less interesting.
    def handle_summary
      ErrorLog.gsub!(/\t(.+?)\n/) do |line|
        if Regexp.last_match[1].start_with?('/')
          downcased = Regexp.last_match[1].downcase
          if downcased.include?('cocoapods') && !downcased.include?('spec/spec_helper')
            line
          else
            "\e[0;37m#{line}\e[0m"
          end
        else
          line
        end
      end
      super
    end
  end

  extend BacktraceFilter
end
