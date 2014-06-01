require 'lib/pod_metrics'

# Only for reading purposes.
#
class Pod < Sequel::Model(:pods)
  include PodMetrics

  plugin :timestamps

  # E.g. Pod.oldest(2)
  #
  def self.oldest(amount = 100)
    order(:updated_at).limit(amount)
  end

  def self.without_github_metrics
    with_github_metrics.where(:pod_id => nil)
  end

  def self.with_old_github_metrics
    with_github_metrics.where('github_metrics.updated_at < ?', Date.today - 3)
  end
end
