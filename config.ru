require File.expand_path('../app', __FILE__)

# Start periodic updating process.
#
require 'updater'

require 'app/controller'
run MetricsApp
