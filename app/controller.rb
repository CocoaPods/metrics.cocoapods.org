require 'sinatra/base'
require 'app/models'

class MetricsApp < Sinatra::Base
  get '/api/v1/status' do
    {
      :github => {
        :total => GithubPodMetrics.count,
        :complete => GithubPodMetrics.where('not_found = 0').count,
        :not_found => GithubPodMetrics.where('not_found > 0').count
      }
    }.to_json
  end

  get '/api/v1/pods/:name' do
    pod = Pod.first(:name => params[:name])
    if pod
      metrics = pod.github_pod_metrics
      if metrics
        github_values = metrics.values
        github_values.delete(:id)
        github_values.delete(:pod_id)
        github_values.delete(:not_found) unless params[:debug]
        return { :github => github_values }.to_json
      end
    end
    {}.to_json
  end

  # Install trunk hook path for POST (ping from trunk).
  #
  post "/hooks/trunk/#{ENV['INCOMING_TRUNK_HOOK_PATH']}" do
    data = JSON.parse(request.body.read)
    pod = Pod.first(:name => data['pod'])
    Metrics::Updater.reset(pod) if pod

    'Metrics ok.'
  end
end
