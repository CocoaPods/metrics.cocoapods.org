require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../app/models', __FILE__)
require File.expand_path('../../../../lib/metrics/github', __FILE__)

describe Metrics::Github do

  describe 'with a .git github URL' do
    before do
      @github = Metrics::Github.new 'https://github.com/myusername/reponame.git'
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
      @github = Metrics::Github.new 'https://github.com/myusername/reponame'
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
      @github = Metrics::Github.new 'git@github.com/myusername/reponame.git'
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
      @github = Metrics::Github.new 'git://github.com/myusername/reponame.git'
    end
    it 'has the right user' do
      @github.user.should == 'myusername'
    end
    it 'has the right repo' do
      @github.repo.should == 'reponame'
    end
  end

  describe 'not_found' do
    before do
      @github = Metrics::Github.new 'https://github.com/myusername/reponame.git'
    end
    it 'updates not found on existing github metrics' do
      pod = Pod.create(:name => 'PodHasMetrics')
      metrics = GithubMetrics.create(:pod_id => pod.id, :not_found => 2)

      @github.not_found(pod)

      metrics.reload.not_found.should == 3
    end
    it 'creates metrics with not found' do
      pod = Pod.create(:name => 'PodNoMetrics')
      pod.github_metrics.nil?.should == true

      @github.not_found(pod)

      pod.reload.github_metrics.not_found.should == 1
    end
  end

end
