require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../../../../app/controller', __FILE__)
require File.expand_path('../../../../../app/models', __FILE__)

describe MetricsApp, '/api/v1/pods/:name' do

  before do
    @pod = Pod.create(:name => 'TestPod1')
    @github_metrics = GithubPodMetrics.create(
      :pod => @pod,
      :subscribers => 404,
      :stargazers => 6322,
      :forks => 1532,
      :contributors => 30,
      :open_issues => 227,
      :open_pull_requests => 30,
      :language => 'Objective-C',
      :not_found => 1,
      :created_at => '2014-06-11 16:40:13 UTC',
      :updated_at => nil
    )
    @cocoadocs_metrics = CocoadocsPodMetrics.create(
      :pod => @pod,
      :download_size => 80_220,
      :total_files => 130,
      :total_comments => 10_297,
      :total_lines_of_code => 27_637,
      :doc_percent => 71,
      :readme_complexity => 40,
      :initial_commit_date => '2015-01-02 10:53:59 UTC',
      :rendered_readme_url => 'http://cocoadocs.org/docsets/Realm/0.89.2/README.html',
      :not_found => 0,
      :created_at => '2015-01-12 00:23:51 UTC',
      :updated_at => '2015-01-12 00:48:25 UTC',
      :license_short_name => 'Apache 2',
      :license_canonical_url => 'https://www.apache.org/licenses/LICENSE-2.0.html',
      :total_test_expectations => 4397
    )
  end

  it 'returns the right details' do
    get "/api/v1/pods/#{@pod.name}"
    last_response.status.should == 200
    last_response.content_type.should == 'application/json'
    JSON.parse(last_response.body).should == {
      'github' => {
        'subscribers' => 404,
        'stargazers' => 6322,
        'forks' => 1532,
        'contributors' => 30,
        'open_issues' => 227,
        'open_pull_requests' => 30,
        'language' => 'Objective-C',
        'created_at' => '2014-06-11 16:40:13 UTC',
        'updated_at' => nil
      },
      'cocoadocs' => {
        'download_size' => 80_220,
        'total_files' => 130,
        'total_comments' => 10_297,
        'total_lines_of_code' => 27_637,
        'doc_percent' => 71,
        'readme_complexity' => 40,
        'initial_commit_date' => '2015-01-02 10:53:59 UTC',
        'rendered_readme_url' => 'http://cocoadocs.org/docsets/Realm/0.89.2/README.html',
        'created_at' => '2015-01-12 00:23:51 UTC',
        'updated_at' => '2015-01-12 00:48:25 UTC',
        'license_short_name' => 'Apache 2',
        'license_canonical_url' => 'https://www.apache.org/licenses/LICENSE-2.0.html',
        'total_test_expectations' => 4397
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
        'language' => 'Objective-C',
        'created_at' => '2014-06-11 16:40:13 UTC',
        'updated_at' => nil
      },
      'cocoadocs' => {
        'download_size' => 80_220,
        'total_files' => 130,
        'total_comments' => 10_297,
        'total_lines_of_code' => 27_637,
        'doc_percent' => 71,
        'readme_complexity' => 40,
        'initial_commit_date' => '2015-01-02 10:53:59 UTC',
        'rendered_readme_url' => 'http://cocoadocs.org/docsets/Realm/0.89.2/README.html',
        'not_found' => 0,
        'created_at' => '2015-01-12 00:23:51 UTC',
        'updated_at' => '2015-01-12 00:48:25 UTC',
        'license_short_name' => 'Apache 2',
        'license_canonical_url' => 'https://www.apache.org/licenses/LICENSE-2.0.html',
        'total_test_expectations' => 4397
      }
    }
  end

end
