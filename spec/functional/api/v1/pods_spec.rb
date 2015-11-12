require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../../../../app/controller', __FILE__)
require File.expand_path('../../../../../app/models', __FILE__)

describe MetricsApp, '/api/v1/pods/:name' do

  before do
    @pods = [
      Pod.create(:name => 'TestPod1'), # base case
      Pod.create(:name => 'TestPod2.IO'), # pod name with periods
      Pod.create(:name => 'TestPod1.IO') # potential collision with 'TestPod1'
    ]

    @github_metrics_index_property = :subscribers
    @github_metrics_base = {
      :subscribers => 404,
      :stargazers => 6_322,
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
    }

    @cocoadocs_metrics_index_property = :total_files
    @cocoadocs_metrics_base = {
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
      :dominant_language => 'Objective C',
      :quality_estimate => 81,
      :builds_independently => true,
      :is_vendored_framework => nil,
      :rendered_changelog_url => 'http://cocoadocs.org/docsets/Expecta/1.0.2/CHANGELOG.html',
      :rendered_summary => nil
    }

    @stats_metrics_index_property = :download_total
    @stats_metrics_base = {
      :download_total => 17_827,
      :download_week => 5_186,
      :download_month => 17_616,
      :app_total => 28,
      :app_week => 3,
      :tests_total => 721,
      :tests_week => 384,
      :created_at => '2015-05-25 09:07:22 UTC',
      :updated_at => '2015-08-17 09:46:37 UTC',
      :extension_week => 0,
      :extension_total => 0,
      :watch_week => 0,
      :watch_total => 0,
      :pod_try_week => 0,
      :pod_try_total => 0,
      :is_active => true
    }

    @pods.each_with_index do |pod, index|
      GithubPodMetrics.create(@github_metrics_base.merge(:pod => pod, @github_metrics_index_property => index))
      CocoadocsPodMetrics.create(@cocoadocs_metrics_base.merge(:pod => pod, @cocoadocs_metrics_index_property => index))
      StatsMetrics.create(@stats_metrics_base.merge(:pod => pod, @stats_metrics_index_property => index))
    end

    @response_json_base = {
      'github' => {
        'subscribers' => 404,
        'stargazers' => 6_322,
        'forks' => 1_532,
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
        'dominant_language' => 'Objective C',
        'quality_estimate' => 81,
        'builds_independently' => true,
        'is_vendored_framework' => nil,
        'rendered_changelog_url' => 'http://cocoadocs.org/docsets/Expecta/1.0.2/CHANGELOG.html',
        'rendered_summary' => nil
      },
      'stats' => {
        'download_total' => 17_827,
        'download_week' => 5_186,
        'download_month' => 17_616,
        'app_total' => 28,
        'app_week' => 3,
        'tests_total' => 721,
        'tests_week' => 384,
        'created_at' => '2015-05-25 09:07:22 UTC',
        'updated_at' => '2015-08-17 09:46:37 UTC',
        'extension_week' => 0,
        'extension_total' => 0,
        'watch_week' => 0,
        'watch_total' => 0,
        'pod_try_week' => 0,
        'pod_try_total' => 0,
        'is_active' => true
      }
    }
  end

  def get_expected_response(index)
    response_json = @response_json_base.dup
    response_json['github'][@github_metrics_index_property.to_s] = index
    response_json['cocoadocs'][@cocoadocs_metrics_index_property.to_s] = index
    response_json['stats'][@stats_metrics_index_property.to_s] = index
    response_json
  end

  it 'returns the right details' do
    @pods.each_with_index do |pod, index|
      get "/api/v1/pods/#{pod.name}"
      last_response.status.should == 200
      last_response.content_type.should == 'application/json'

      JSON.parse(last_response.body).should == get_expected_response(index)
    end
  end

  it 'accepts a correctly parses a .json suffix' do
    @pods.each_with_index do |pod, index|
      get "/api/v1/pods/#{pod.name}.json"
      last_response.status.should == 200
      last_response.content_type.should == 'application/json'

      JSON.parse(last_response.body).should == get_expected_response(index)
    end
  end

  it 'shows debug details when needed' do
    @pods.each_with_index do |pod, index|
      get "/api/v1/pods/#{pod.name}?debug=true"
      last_response.status.should == 200
      debug_json = get_expected_response(index)
      debug_json['github']['not_found'] = 1
      JSON.parse(last_response.body).should == debug_json
    end
  end

end
