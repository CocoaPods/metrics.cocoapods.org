require 'sinatra/base'

class MetricsApp < Sinatra::Base
  # Install trunk hook path for both GET (comfy manual) and POST (ping from trunk).
  #
  %w(get post).each do |type|
    send(type, "/hooks/trunk/#{ENV['INCOMING_TRUNK_HOOK_PATH']}") do
      'Metrics ok.'
    end
  end
end