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
      :closed_issues => 920,
      :open_pull_requests => 30,
      :closed_pull_requests => 10,
      :language => 'Objective-C',
      :not_found => 1,
      :created_at => '2014-06-11 16:40:13 UTC',
      :updated_at => nil
    )
    @cocoadocs_metrics = CocoadocsPodMetrics.create(
      :pod => @pod,
      :total_files => 130,
      :total_comments => 10_297,
      :total_lines_of_code => 27_637,
      :doc_percent => 71,
      :readme_complexity => 40,
      :initial_commit_date => '2015-01-02 10:53:59 UTC',
      :rendered_readme_url => 'http://cocoadocs.org/docsets/Realm/0.89.2/README.html',
      :created_at => '2015-01-12 00:23:51 UTC',
      :updated_at => '2015-01-12 00:48:25 UTC',
      :license_short_name => 'Apache 2',
      :license_canonical_url => 'https://www.apache.org/licenses/LICENSE-2.0.html',
      :total_test_expectations => 4397,
      :dominant_language => "Objective C",
      :quality_estimate => 81,
      :builds_independently => true,
      :is_vendored_framework => nil,
      :rendered_changelog_url => "http://cocoadocs.org/docsets/Expecta/1.0.2/CHANGELOG.html",
      :rendered_summary => nil
    )
    @stats_metrics = StatsMetrics.create(
      :pod => @pod,
      :download_total => 17827,
      :download_week => 5186,
      :download_month => 17616,
      :app_total => 28,
      :app_week => 3,
      :tests_total => 721,
      :tests_week => 384,
      :created_at => "2015-05-25 09:07:22 UTC",
      :updated_at => "2015-08-17 09:46:37 UTC",
      :extension_week => 0,
      :extension_total => 0,
      :watch_week => 0,
      :watch_total => 0,
      :pod_try_week => 0,
      :pod_try_total => 0,
      :is_active => true
    )
  end

  response_json = {
    'github' => {
      'subscribers' => 404,
      'stargazers' => 6322,
      'forks' => 1532,
      'contributors' => 30,
      'open_issues' => 227,
      'closed_issues' => 920,
      'open_pull_requests' => 30,
      'closed_pull_requests' => 10,
      'language' => 'Objective-C',
      'created_at' => '2014-06-11 16:40:13 UTC',
      'updated_at' => nil,
    },
    'cocoadocs' => {
      'install_size' => nil,
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
      'total_test_expectations' => 4397,
      "dominant_language" => "Objective C",
      "quality_estimate" => 81,
      "builds_independently" => true,
      "is_vendored_framework" => nil,
      "rendered_changelog_url" => "http://cocoadocs.org/docsets/Expecta/1.0.2/CHANGELOG.html",
      "rendered_summary" => nil
    },
    'stats' => {
      "download_total" => 17827,
      "download_week" => 5186,
      "download_month" => 17616,
      "app_total" => 28,
      "app_week" => 3,
      "tests_total" => 721,
      "tests_week" => 384,
      "created_at" => "2015-05-25 09:07:22 UTC",
      "updated_at" => "2015-08-17 09:46:37 UTC",
      "extension_week" => 0,
      "extension_total" => 0,
      "watch_week" => 0,
      "watch_total" => 0,
      "pod_try_week" => 0,
      "pod_try_total" => 0,
      "is_active" => true
    }
  }

  it 'returns the right details' do
    get "/api/v1/pods/#{@pod.name}"
    last_response.status.should == 200
    last_response.content_type.should == 'application/json'

    JSON.parse(last_response.body).should == response_json
  end

  it 'shows debug details when needed' do
    get "/api/v1/pods/#{@pod.name}?debug=true"
    last_response.status.should == 200
    debug_json = response_json
    debug_json['github']["not_found"] = 1
    JSON.parse(last_response.body).should == debug_json
  end

end
