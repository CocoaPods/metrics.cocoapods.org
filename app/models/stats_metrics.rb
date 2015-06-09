require 'lib/pod_metrics'

class StatsMetrics < Sequel::Model(:stats_metrics)
  include PodMetrics
end
