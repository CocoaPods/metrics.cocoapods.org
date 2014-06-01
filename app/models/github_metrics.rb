require 'lib/pod_metrics'

class GithubMetrics < Sequel::Model(:github_metrics)
  include PodMetrics

  plugin :timestamps
end
