# Only for reading purposes.
#
class Pod < Sequel::Model(:pods)
  one_to_one :metrics

  # E.g. Pod.with_metrics.first[:github_stars]
  #
  def self.with_metrics
    Pod.join(:metrics, :pod_id => :id)
  end
end
