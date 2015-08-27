require File.expand_path('../github', __FILE__)
require 'app/models'

module Metrics
  # Runs a child process where pods are updated periodically.
  #
  # TODO: At some point add a state to metrics "failed" to indicate to not retry loading the metrics.
  #
  class Updater
    def self.amount
      100
    end

    def self.start
      run_child_process
    end

    def self.run_child_process
      DB.disconnect
      @child_id = fork do
        loop do
          pods = find_pods_without_github_pod_metrics(amount / 2)
          if pods.size < amount
            pods += find_pods_with_old_github_pod_metrics(amount - pods.size)
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
        Metrics::Github.new.update(pod)
      end
    rescue StandardError => e
      if ENV['RACK_ENV'] == 'production'
        sleep 10
      else
        raise e
      end
    rescue RateLimitError => e
      if e.resets_at
        sleep_time = (e.resets_at - Time.now.to_i) + 10
        sleep sleep_time if sleep_time > 0
      else
        sleep 4000
      end
    end

    # Instruct updater to re-evaluate pod.
    #
    # This should reset all e.g. not_found counters.
    #
    def self.reset(pod)
      Metrics::Github.new.reset_not_found(pod)
    end

    def self.find_pods_without_github_pod_metrics(update_amount = amount)
      Pod.without_github_pod_metrics
        .order(Sequel.lit('RANDOM()'))
        .limit(update_amount)
        .all
    end

    def self.find_pods_with_old_github_pod_metrics(update_amount = amount)
      Pod.with_old_github_pod_metrics
        .order(Sequel.lit('RANDOM()'))
        .where('github_pod_metrics.not_found < 3')
        .limit(update_amount)
        .all
    end

    def self.stop
      Process.kill 'INT', @child_id if @child_id
    rescue
      'RuboCop: Do not suppress exceptions.'
    ensure
      Process.waitall
    end
  end
end

at_exit { Metrics::Updater.stop }
