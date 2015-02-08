require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../app/models', __FILE__)
require File.expand_path('../../../../lib/metrics/github', __FILE__)

describe Metrics::Github do

  describe 'with a dot in the repository name' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('https://github.com/kylef/URITemplate.swift.git')
    end

    it 'has the right user' do
      @github.user.should == 'kylef'
    end

    it 'has the right repo' do
      @github.repo.should == 'URITemplate.swift'
    end
  end

  describe 'with a .git github URL' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('https://github.com/myusername/reponame.git')
    end
    it 'has the right user' do
      @github.user.should == 'myusername'
    end
    it 'has the right repo' do
      @github.repo.should == 'reponame'
    end
  end

  describe 'with a non .git github URL' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('https://github.com/myusername/reponame')
    end
    it 'has the right user' do
      @github.user.should == 'myusername'
    end
    it 'has the right repo' do
      @github.repo.should == 'reponame'
    end
  end

  describe 'with a private github URL' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('git@github.com/myusername/reponame.git')
    end
    it 'has the right user' do
      @github.user.should == 'myusername'
    end
    it 'has the right repo' do
      @github.repo.should == 'reponame'
    end
  end

  describe 'with a ? github URL' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('git://github.com/myusername/reponame.git')
    end
    it 'has the right user' do
      @github.user.should == 'myusername'
    end
    it 'has the right repo' do
      @github.repo.should == 'reponame'
    end
  end

  describe 'with an error case' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('https://github.com/RestKit/RestKit.git')
    end
    it 'has the right user' do
      @github.user.should == 'RestKit'
    end
    it 'has the right repo' do
      @github.repo.should == 'RestKit'
    end
  end

  describe 'not_found' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('https://github.com/myusername/reponame.git')
    end
    it 'updates not found on existing github metrics' do
      pod = Pod.create(:name => 'PodHasMetrics')
      metrics = GithubPodMetrics.create(:pod_id => pod.id, :not_found => 2)

      @github.not_found(pod)

      metrics.reload.not_found.should == 3
    end
    it 'creates metrics with not found' do
      pod = Pod.create(:name => 'PodNoMetrics')
      pod.github_pod_metrics.nil?.should == true

      @github.not_found(pod)

      pod.reload.github_pod_metrics.not_found.should == 1
    end
  end

  describe 'reset_not_found' do
    before do
      @github = Metrics::Github.new
    end
    it 'resets not found on existing github metrics' do
      pod = Pod.create(:name => 'PodHasMetrics')
      metrics = GithubPodMetrics.create(:pod_id => pod.id, :not_found => 2)

      @github.reset_not_found(pod)

      metrics.reload.not_found.should == 0
    end
    it 'ignores metrics with no not found' do
      pod = Pod.create(:name => 'PodNoMetrics')
      pod.github_pod_metrics.nil?.should == true

      @github.reset_not_found(pod)

      pod.github_pod_metrics.nil?.should == true
    end
  end

  describe '.update' do
    def stub_request_with_fixture(fixture, url)
      fixture_path = File.expand_path("../../../fixtures/#{fixture}.json", __FILE__)
      response = File.read(fixture_path)
      stub_request(:get, url)
        .to_return(response)
    end

    before do
      @pod = Pod.create(:name => 'AFNetworking')
      GithubPodMetrics.create(:pod => @pod)
      @pod.expects(:github_url).returns('https://github.com/AFNetworking/AFNetworking')

      @github = Metrics::Github.new
    end

    it 'raises RateLimitError when rate limiting is in effect' do
      stub_request_with_fixture('repos_afnetworking_rate_limit',
                                'https://api.github.com/repos/AFNetworking/AFNetworking')

      should.raise(Metrics::Github::RateLimitError) { @github.update(@pod) }
    end

    it 'updates correctly' do
      stub_request_with_fixture('repos_afnetworking',
                                'https://api.github.com/repos/AFNetworking/AFNetworking')
      stub_request_with_fixture('repos_afnetworking_pulls',
                                'https://api.github.com/repos/AFNetworking/AFNetworking/pulls?per_page=10&state=open')
      stub_request_with_fixture('repos_afnetworking_contributors_first_page',
                                'https://api.github.com/repos/AFNetworking/AFNetworking/contributors?per_page=10')
      stub_request_with_fixture('repos_afnetworking_contributors_last_page',
                                'https://api.github.com/repositories/1828795/contributors?per_page=10&page=23')

      expected_result = {
        :subscribers => 1261,
        :stargazers => 157_21,
        :forks => 4483,
        :contributors => 225,
        :open_issues => 29,
        :open_pull_requests => 6,
        :language => 'Objective-C'
      }

      @github.update(@pod)

      result = GithubPodMetrics.find(:pod_id => @pod.id).values

      expected_result.each { |key, value| result[key].should == value }
    end
  end
end
