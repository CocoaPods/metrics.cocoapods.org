require 'bacon'
require 'pretty_bacon'

require 'rack/test'
require 'digest'

require 'mocha-on-bacon'
Mocha::Configuration.prevent(:stubbing_non_existent_method)

require 'cocoapods-core'

ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../../', __FILE__)
require 'config/init'
require 'app'

$LOAD_PATH.unshift(ROOT, 'spec')
Dir.glob(File.join(ROOT, 'spec/spec_helper/**/*.rb')).each do |filename|
  require File.join('spec_helper', File.basename(filename, '.rb'))
end

class Should
  include SpecHelpers::ModelAssertions
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
