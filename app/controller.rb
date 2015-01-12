require 'sinatra/base'
require 'app/models'

class MetricsApp < Sinatra::Base
  set :protection, :except => :json_csrf
  
  def sanitize_metrics(metrics, debug = false)
    return unless metrics
    metrics = metrics.values.dup
    metrics.delete(:id)
    metrics.delete(:pod_id)
    metrics.delete(:not_found) unless debug
    metrics
  end

  before do
    type = content_type(:json)
  end

  def json_error(status, message)
    error(status, { 'error' => message }.to_json)
  end

  def json_message(status, content)
    halt(status, content.to_json)
  end

  get '/api/v1/status' do
    {
      :github => {
        :total => GithubPodMetrics.count,
        :complete => GithubPodMetrics.where('not_found = 0').count,
        :not_found => GithubPodMetrics.where('not_found > 0').count,
      },
      :cocoadocs => {
        :total => CocoadocsPodMetrics.count,
      }
    }.to_json
  end

  get '/api/v1/pods/:name.?:format?' do
    format = params[:format]
    if !format || format == 'json'
      pod = Pod.first(:name => params[:name])
      if pod
        github_metrics = pod.github_pod_metrics
        cocoadocs_metrics = pod.cocoadocs_pod_metrics
        if github_metrics || cocoadocs_metrics
          json_message(
            200,
            :github => sanitize_metrics(github_metrics, params[:debug]),
            :cocoadocs => sanitize_metrics(cocoadocs_metrics, params[:debug]),
          )
        end
      end
    end
    json_error(404, 'No pod found with the specified name.')
  end

  post "/api/v1/pods/:name/reset/#{ENV['INCOMING_TRUNK_HOOK_PATH']}" do
    pod = Pod.first(:name => params[:name])
    if pod
      if Metrics::Github.new.reset_not_found(pod)
        # Also directly try to update.
        Metrics::Github.new.update(pod)
        "#{pod.name} reset."
      else
        "#{pod.name} not reset."
      end
    end
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
