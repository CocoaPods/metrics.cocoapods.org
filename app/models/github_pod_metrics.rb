require 'lib/pod_metrics'

class GithubPodMetrics < Sequel::Model(:github_pod_metrics)
  include PodMetrics

  plugin :timestamps
end
