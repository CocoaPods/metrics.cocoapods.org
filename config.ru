require 'bundler/setup'

$:.unshift File.expand_path('..', __FILE__)
require 'config/init'

# Start periodic updating process.
#
METRICS_APP_LOGGER.info "Starting Metrics::Updater."
require 'lib/metrics/updater'
Metrics::Updater.start

require 'app/controller'
run MetricsApp
