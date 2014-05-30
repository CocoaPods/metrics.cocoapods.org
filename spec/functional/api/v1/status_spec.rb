require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../../../../app/controller', __FILE__)
require File.expand_path('../../../../../app/models/github_metrics', __FILE__)
require File.expand_path('../../../../../app/models/pod', __FILE__)

describe MetricsApp, '/api/v1/status' do

  before do
    pod = Pod.create(:name => 'TestPod1')
    GithubMetrics.create(
      :pod => pod,
      :stars => 12,
      :pull_requests => 1
    )
    pod = Pod.create(:name => 'TestPod2')
    GithubMetrics.create(
      :pod => pod,
      :stars => 1001,
      :pull_requests => 23
    )
  end

  it 'returns the right amount' do
    get '/api/v1/status'
    last_response.status.should == 200
    JSON.parse(last_response.body).should == { 'github' => 2 }
  end

end
