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

end
