require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../app/controller', __FILE__)
require File.expand_path('../../../lib/metrics/updater', __FILE__)

describe MetricsApp, 'when receiving hook calls from trunk' do

  def post_spec_update
    post '/hooks/trunk/', '{"pod":"pod_name","version":"1.0.0","commit":"abcd"}'
  end

  it 'succeeds without a pod' do
    Metrics::Updater.expects(:reset).never

    post_spec_update

    last_response.status.should == 200
  end

  it 'resets metrics with a pod' do
    pod = Pod.create(:name => 'pod_name')

    Metrics::Updater.expects(:reset).once.with(pod)

    post_spec_update

    last_response.status.should == 200
  end

  it 'redirects root to status' do
    get "/"
    follow_redirect!
    last_request.url.should == "http://example.org/api/v1/status"
  end


end
