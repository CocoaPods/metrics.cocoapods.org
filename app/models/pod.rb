require 'lib/pod_metrics'
require File.expand_path '../version', __FILE__

# Only for reading purposes.
#
class Pod < Sequel::Model(:pods)
  # Currently adds:
  #   * Pod#github_pod_metrics (one_to_one)
  #   * Pod.with_github_pod_metrics
  #
  include PodMetrics

  one_to_many :versions

  plugin :timestamps

  # E.g. Pod.oldest(2)
  #
  def self.oldest(amount = 100)
    order(:updated_at).limit(amount)
  end

  def self.without_github_pod_metrics
    with_github_pod_metrics.where(:pod_id => nil)
  end

  def self.with_old_github_pod_metrics
    with_github_pod_metrics.where(
      'github_pod_metrics.updated_at <= ? OR github_pod_metrics.updated_at IS NULL',
      Date.today - 1
    )
  end

  def specification_json
    # TODO: Also sort Commits correctly.
    #
    version = versions.sort_by { |v| Gem::Version.new(v.name) }.last
    commit = version.commits.last if version
    commit.specification_data if commit
  end

  def specification_data
    JSON.parse(specification_json || '{}')
  end

  def github_url
    data = specification_data
    source = data['source'] || {}
    git = source['git']
    git if git =~ %r{github.com[:/]+.+/.+}
  end
end
