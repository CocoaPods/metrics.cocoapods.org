require 'github_api'
require 'rest'
require 'json'

module Metrics
  class Github
    ITEMS_PER_PAGE = 10

    attr_reader :user, :repo

    class ParseError < StandardError; end
    class RateLimitError < StandardError
      attr_reader :resets_at, :limit

      def initialize(limit, resets_at)
        super('Rate Limit exceeded')

        @limit = limit
        @resets_at = resets_at
      end
    end

    def initialize_client_with_repo_address(url)
      @user, @repo = parse url
      params = {
        :user => @user,
        :repo => @repo
      }
      github_client params
    end

    def github_client params
      if ENV['GITHUB_BOT_USER'] && ENV['GITHUB_BOT_PASS']
        params[:basic_auth] = "#{ENV['GITHUB_BOT_USER']}:#{ENV['GITHUB_BOT_PASS']}"
      end
      ::Github.new(params)
    end

    # Updates a GithubPodMetrics model with the latest Github data.
    #
    def update(pod)
      if url = pod.github_url
        client = initialize_client_with_repo_address(url)
        repo = client.repos.find
        client, repo = check_repo_redirection(client, repo)

        check_rate_limiting(repo)
        GithubPodMetrics.update_or_create({ :pod_id => pod.id }, update_hash(client, repo))

        reset_not_found(pod)
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
      closed_issues = total_count_of(:closed_issues, client)
      closed_pull_requests = total_count_of(:closed_pull_requests, client)
      open_pull_requests = total_count_of(:open_pull_requests, client)
      {
        :subscribers => repo.subscribers_count,
        :stargazers => repo.stargazers_count,
        :forks => repo.forks_count,
        :contributors => total_count_of(:contributors, client),
        # Because every PR is an issue we subtract the closed/open PRs
        # from the closed/open issues
        :open_issues => repo.open_issues_count - open_pull_requests,
        :closed_issues => closed_issues - closed_pull_requests,
        :open_pull_requests => open_pull_requests,
        :closed_pull_requests => closed_pull_requests,
        :language => repo.language
      }
    end

    def handle_update_error(e, pod)
      case e.message
      when /404 Not Found/
        not_found(pod)
      when /403 API rate limit exceeded/
        headers = ::Github::Response::Header.new response_headers: e.http_headers
        raise build_rate_limit_error(headers)
      else
        # Only log out when there's an unexpected error, vs expected errors
        METRICS_APP_LOGGER.error e
        raise
      end
    end

    def check_rate_limiting(response)
      remaining = response.headers.ratelimit_remaining
      raise build_rate_limit_error(response.headers) if remaining.nil? || remaining.to_i <= 0
    end

    # Support GitHub's repo redirection feature
    #
    def check_repo_redirection(client, repo)
      if repo.respond_to?(:redirect?) && repo.redirect?
          redirect_details = REST.get(repo.url).body
          url = JSON.parse(redirect_details)["url"]

          new_repo_details = REST.get(url).body
          url = JSON.parse(new_repo_details)["url"]

          client = initialize_client_with_repo_address url
          repo = client.repos.find
      end
       [client, repo]
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

    def total_count_of(collection, client)
      case collection
      when :contributors
        result = client.repos.contributors(:per_page => ITEMS_PER_PAGE)
      when :open_pull_requests
        result = client.pull_requests.all(:state => 'open',
                                          :per_page => ITEMS_PER_PAGE)
      when :closed_pull_requests
        result = client.pull_requests.all(:state => 'closed',
                                          :per_page => ITEMS_PER_PAGE)
      when :closed_issues
        result = client.issues.list(:state => 'closed',
                                    :per_page => ITEMS_PER_PAGE,
                                    :user => client.user,
                                    :repo => client.repo)
      else
        raise 'Unsupported collection'
      end

      # Stop early if the first page contained all items
      return result.size if result.size < ITEMS_PER_PAGE
      page_count = result.count_pages

      last = result.last_page
      return result.size if last.nil?

      ITEMS_PER_PAGE * (page_count - 1) + last.size
    end

    def build_rate_limit_error(headers)
      resets_at = headers.ratelimit_reset.to_i
      limit = headers.ratelimit_limit.to_i

      resets_at = Time.now.to_i + 4000 if resets_at == 0
      raise RateLimitError.new(limit, resets_at)
    end

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
