require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../../../../app/controller', __FILE__)
require File.expand_path('../../../../../app/models', __FILE__)

describe MetricsApp, '/api/v1/pods/:name' do

  before do
    @pod = Pod.create(:name => 'TestPod1')
    @metrics = GithubPodMetrics.create(
      :pod => @pod,
      :subscribers => 404,
      :stargazers => 6322,
      :forks => 1532,
      :contributors => 30,
      :open_issues => 227,
      :open_pull_requests => 30,
      :not_found => 1,
      :created_at => '2014-06-11 16:40:13 UTC',
      :updated_at => nil
    )
  end

  it 'returns the right details' do
    get "/api/v1/pods/#{@pod.name}"
    last_response.status.should == 200
    JSON.parse(last_response.body).should == {
      'github' => {
        'subscribers' => 404,
        'stargazers' => 6322,
        'forks' => 1532,
        'contributors' => 30,
        'open_issues' => 227,
        'open_pull_requests' => 30,
        'created_at' => '2014-06-11 16:40:13 UTC',
        'updated_at' => nil
      }
    }
  end

  it 'returns the right details' do
    get "/api/v1/pods/#{@pod.name}?debug=true"
    last_response.status.should == 200
    JSON.parse(last_response.body).should == {
      'github' => {
        # 'id' => @metrics.id,
        # 'pod_id' => @pod.id,
        'subscribers' => 404,
        'stargazers' => 6322,
        'forks' => 1532,
        'contributors' => 30,
        'open_issues' => 227,
        'open_pull_requests' => 30,
        'not_found' => 1,
        'created_at' => '2014-06-11 16:40:13 UTC',
        'updated_at' => nil
      }
    }
  end

end
