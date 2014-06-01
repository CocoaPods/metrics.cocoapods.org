require 'github_api'

module Metrics
  class Github
    attr_reader :user, :repo, :client

    def initialize(url)
      @user, @repo = parse url
      @client = ::Github.new(:user => @user, :repo => @repo)
    end

    # Updates a GithubMetrics model with the latest Github data.
    #
    def update(metrics_model)
      r = client.repos.find

      metrics_model.update(
        :subscribers => r.subscribers_count,
        :stargazers => r.stargazers_count,
        :forks => r.forks_count,
        :contributors => client.repos.contributors.size,
        :open_issues => r.open_issues_count,
        :open_pull_requests => client.pull_requests.all.size
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
