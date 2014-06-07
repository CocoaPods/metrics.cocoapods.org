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
        begin
          # Dis- and Reconnect the database.
          #
          opts = Sequel::Model.db.opts
          DB.disconnect
          Sequel.connect(opts[:uri], opts[:orig_opts])

          loop do
            pods = find_pods_without_github_metrics.limit(10).all
            if pods.empty?
              pods = find_pods_with_old_github_metrics.limit(10).all
            end
            if pods.empty?
              next
            else
              update pods
            end
          end
        rescue StandardError => e
          sleep 10
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
      Pod.without_github_metrics
    end

    def self.find_pods_with_old_github_metrics
      Pod.with_old_github_metrics
    end

    def self.stop
      Process.kill 'INT', @child_id if @child_id
    rescue
      'RuboCop: Do not suppress exceptions.'
    end
  end
end

at_exit { Metrics::Updater.stop }
