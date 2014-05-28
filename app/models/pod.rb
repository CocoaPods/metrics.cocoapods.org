# Only for reading purposes.
#
class Pod < Sequel::Model(:pods)
  one_to_one :metrics

  plugin :timestamps

  # E.g. Pod.with_metrics.first[:github_stars]
  #
  def self.with_metrics
    left_join(:metrics, :pod_id => :id)
  end
  def self.oldest(amount = 100)
    order(:updated_at).limit(amount)
  end
end
