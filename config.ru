require 'bundler/setup'

$:.unshift File.expand_path('..', __FILE__)
require 'config/init'

require 'lib/metrics/updater'
Metrics::Updater.start

require 'app/controller'
run MetricsApp
