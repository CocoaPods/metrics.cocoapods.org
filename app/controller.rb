require 'sinatra/base'
require 'app/models'

class MetricsApp < Sinatra::Base
  get '/api/v1/status' do
    {
      :github => {
        :total => GithubMetrics.count,
        :complete => GithubMetrics.where('not_found = 0').count,
        :not_found => GithubMetrics.where('not_found > 0').count
      }
    }.to_json
  end

  get '/api/v1/pods/:name' do
    pod = Pod.first(:name => params[:name])
    if pod
      metrics = pod.github_metrics
      if metrics
        github_values = metrics.values
        github_values.delete(:id)
        github_values.delete(:pod_id)
        return { :github => github_values }.to_json
      end
    end
    {}.to_json
  end

  # Install trunk hook path for both GET (comfy manual) and POST (ping from trunk).
  #
  %w(get post).each do |type|
    send(type, "/hooks/trunk/#{ENV['INCOMING_TRUNK_HOOK_PATH']}") do
      'Metrics ok.'
    end
  end
end
