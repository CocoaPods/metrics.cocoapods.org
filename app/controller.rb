require 'sinatra/base'
require 'app/models'

class MetricsApp < Sinatra::Base
  get '/api/v1/status' do
    { :github => GithubMetrics.count }.to_json
  end

  get '/api/v1/pods/:name' do
    pod = Pod.first(:name => params[:name])
    github_values = pod.github_metrics.values
    github_values.delete(:id)
    github_values.delete(:pod_id)
    { :github => github_values }.to_json
  end

  # Install trunk hook path for both GET (comfy manual) and POST (ping from trunk).
  #
  %w(get post).each do |type|
    send(type, "/hooks/trunk/#{ENV['INCOMING_TRUNK_HOOK_PATH']}") do
      'Metrics ok.'
    end
  end
end
