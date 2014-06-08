require File.expand_path('../github', __FILE__)
require 'app/models'

module Metrics
  # Runs a child process where pods are updated periodically.
  #
  class Updater
    def self.start
      run_child_process
    end

    def self.run_child_process
      @child_id = fork do
        loop do
          pods = find_pods_without_github_metrics
          if pods.empty?
            pods = find_pods_with_old_github_metrics
          end
          if pods.empty?
            sleep 10
          else
            update pods
          end
        end
      end
    end

    # Update each pod.
    #
    def self.update(pods)
      pods.each do |pod|
        if url = pod.github_url
          github = Metrics::Github.new(url)
          github.update(pod)
        end
      end
    rescue StandardError => e
      METRICS_APP_LOGGER.error e
      # TODO: Log.
      sleep 4000 # Back off for more than an hour.
    end

    def self.find_pods_without_github_metrics
      Pod.without_github_metrics.order(Sequel.lit('RANDOM()')).limit(100).all
    end

    def self.find_pods_with_old_github_metrics
      Pod.with_old_github_metrics.order(Sequel.lit('RANDOM()')).limit(100).all
    end

    def self.stop
      Process.kill 'INT', @child_id if @child_id
    rescue
      'RuboCop: Do not suppress exceptions.'
    end
  end
end

at_exit { Metrics::Updater.stop }
