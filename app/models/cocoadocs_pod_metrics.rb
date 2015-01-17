require 'lib/pod_metrics'

class CocoadocsPodMetrics < Sequel::Model(:cocoadocs_pod_metrics)
  include PodMetrics
end
