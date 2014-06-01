require 'app/models'

module Metrics
  # Runs a child process where pods are updated periodically.
  #
  class Updater
    def self.start
      run_child_process
    end

    def self.run_child_process
      puts 'Metrics updating process started.'
      @child_id = fork do
        puts 'Before loop'
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
      end
    end

    # Update each pod.
    #
    def self.update(pods)
      pods.each do |pod|
        # TODO: Update like so:
        # url = ... # Github URL from pod data.
        # github = Metrics::Github.new(url)
        # github.update(pod)
        #
        sleep 100
        puts pod # Rubocop made me do it.
      end
    rescue StandardError
      # TODO: Log.
      sleep 10
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
