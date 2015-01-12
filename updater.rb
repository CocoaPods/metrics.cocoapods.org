require File.expand_path('../app', __FILE__)

require 'lib/metrics/updater'
Metrics::Updater.start
