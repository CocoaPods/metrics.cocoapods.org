require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../../../../app/controller', __FILE__)
require File.expand_path('../../../../../app/models', __FILE__)

describe MetricsApp, '/api/v1/status' do

  before do
    pod = Pod.create(:name => 'TestPod1')
    GithubPodMetrics.create(
      :pod => pod,
      :stargazers => 12,
      :open_pull_requests => 1
    )
    pod = Pod.create(:name => 'TestPod2')
    GithubPodMetrics.create(
      :pod => pod,
      :stargazers => 1001,
      :open_pull_requests => 23
    )
    pod = Pod.create(:name => 'TestPod3')
    GithubPodMetrics.create(
      :pod => pod,
      :not_found => 2
    )
  end

  it 'returns the right amount' do
    get '/api/v1/status'
    last_response.status.should == 200
    JSON.parse(last_response.body).should == {
      'github' => {
        'total' => 3,
        'complete' => 2,
        'not_found' => 1
      }
    }
  end

end
