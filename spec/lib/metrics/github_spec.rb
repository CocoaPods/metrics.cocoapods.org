require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../app/models', __FILE__)
require File.expand_path('../../../../lib/metrics/github', __FILE__)

describe Metrics::Github do

  describe 'with a github URL' do
    before do
      @github = Metrics::Github.new 'https://github.com/lakesoft/LKAssetsLibrary.git'
    end
    it 'has the right user' do
      @github.user.should == 'lakesoft'
    end
    it 'has the right repo' do
      @github.repo.should == 'LKAssetsLibrary'
    end
    # it 'updates the metrics model correctly' do
    #   pod = Pod.create(:name => 'MetricsTestPod')
    #   metrics = GithubMetrics.create(:pod => pod)
    #   @github.update metrics
    #   metrics.should == ''
    # end
  end

end
