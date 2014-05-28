require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../app/models/github_metrics', __FILE__)
require File.expand_path('../../../app/models/pod', __FILE__)

describe Pod do

  describe '.with_github_metrics' do
    before do
      @pod = Pod.create(:name => 'TestPod1')
      @metrics = GithubMetrics.create(
        :pod => @pod,
        :stars => 12,
        :pull_requests => 1
      )
      @pod = Pod.create(:name => 'TestPod2')
      @metrics = GithubMetrics.create(
        :pod => @pod,
        :stars => 1001,
        :pull_requests => 23
      )
    end
    it 'returns a combined model' do
      result = Pod.with_github_metrics.all
      result.map(&:github_stars).should == [12, 1001]
      result.map(&:github_pull_requests).should == [1, 23]
    end
  end

  describe '.oldest' do
    before do
      Pod.create(:name => 'OldestPod')
      Pod.create(:name => 'YoungerPod')
      Pod.create(:name => 'YoungestPod')
    end
    it 'returns the least recently updated X pods' do
      Pod.oldest(2).map(&:name).should == %w(OldestPod YoungerPod)
    end
  end

end
