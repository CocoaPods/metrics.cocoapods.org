require 'github_api'

module Metrics
  class Github
    attr_reader :user, :repo, :client

    def initialize(url)
      @user, @repo = parse url

      params = {
        :user => @user,
        :repo => @repo
      }
      if ENV['GITHUB_BOT_USER'] && ENV['GITHUB_BOT_PASS']
        params[:basic_auth] = "#{ENV['GITHUB_BOT_USER']}:#{ENV['GITHUB_BOT_PASS']}"
      end
      @client = ::Github.new(params)
    end

    # Updates a GithubMetrics model with the latest Github data.
    #
    def update(pod)
      r = client.repos.find

      GithubMetrics.update_or_create(
        { :pod_id => pod.id },
        {
          :subscribers => r.subscribers_count,
          :stargazers => r.stargazers_count,
          :forks => r.forks_count,
          :contributors => client.repos.contributors.size,
          :open_issues => r.open_issues_count,
          :open_pull_requests => client.pull_requests.all.size
          # first_commit
          # last_commit
        }
      )
    end

    private

    # Takes a URL like
    #   https://github.com/lakesoft/LKAssetsLibrary.git
    # and finds its user/repo:
    #   lakesoft and LKAssetsLibrary
    #
    def parse(url)
      matches = url.match(%r{(?<user>[^/]+)/(?<repo>[^/]+)\.git})
      [matches[:user], matches[:repo]]
    end
  end
end
