require 'lib/metrics'

class GithubMetrics < Sequel::Model(:github_metrics)
  include Metrics

  plugin :timestamps
end
