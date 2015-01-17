require 'github_api'

module Metrics
  class Github
    attr_reader :user, :repo

    class ParseError < StandardError; end

    def initialize_client(url)
      @user, @repo = parse url

      params = {
        :user => @user,
        :repo => @repo
      }
      if ENV['GITHUB_BOT_USER'] && ENV['GITHUB_BOT_PASS']
        params[:basic_auth] = "#{ENV['GITHUB_BOT_USER']}:#{ENV['GITHUB_BOT_PASS']}"
      end
      ::Github.new(params)
    end

    # Updates a GithubPodMetrics model with the latest Github data.
    #
    def update(pod)
      if url = pod.github_url
        client = initialize_client(url)

        repo = client.repos.find

        GithubPodMetrics.update_or_create({ :pod_id => pod.id }, update_hash(client, repo))

        reset_not_found(pod)

        sleep 1
      else
        # Not having a Github URL counts as not found in the Github context.
        #
        not_found(pod)
      end
    rescue ParseError
      not_found(pod)
    rescue StandardError => e
      handle_update_error(e, pod)
    end

    def update_hash(client, repo)
      {
        :subscribers => repo.subscribers_count,
        :stargazers => repo.stargazers_count,
        :forks => repo.forks_count,
        :contributors => client.repos.contributors.size,
        :open_issues => repo.open_issues_count,
        :open_pull_requests => client.pull_requests.all.size,
        :language => repo.language
      }
    end

    def handle_update_error(e, pod)
      METRICS_APP_LOGGER.error e
      case e.message
      when /404 Not Found/
        not_found(pod)
      when /403 API rate limit exceeded/
        sleep 4000 # Wait until the rate limit is over.
      else
        raise
      end
    end

    # Adds 1 to a GithubPodMetrics model's not found attribute.
    #
    def not_found(pod)
      metrics = pod.github_pod_metrics

      if metrics
        metrics.update(:not_found => (metrics.not_found + 1))
      else
        GithubPodMetrics.create(:pod_id => pod.id, :not_found => 1)
      end
    end

    def reset_not_found(pod)
      metrics = pod.github_pod_metrics
      if metrics
        metrics.update(:not_found => 0)
        metrics
      end
    end

    private

    # Takes a URL like
    #   https://github.com/lakesoft/LKAssetsLibrary.git
    # and finds its user/repo:
    #   lakesoft and LKAssetsLibrary
    #
    def parse(url)
      matches = url.match(%r{[:/](?<user>[^/]+)/(?<repo>[^/]+)\z})
      [matches[:user], matches[:repo].gsub(/\.git\z/, '')]
    rescue StandardError => e
      raise ParseError, 'Can not parse Github URL.'
    end
  end
end
