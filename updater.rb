require File.expand_path('../app', __FILE__)

require 'lib/metrics/updater'

# Default to updaing all
if ARGV.length == 0
  Metrics::Updater.start

# If you provide another param, take that as
# wanting to look at a specific pod
else
  pod_name = ARGV.first
  puts "Looking at #{pod_name}"
  pod = Pod.where(:name => ARGV.first).first

  abort("Could not find Pod in database") unless pod
  Metrics::Updater.update([pod]) if pod
end
