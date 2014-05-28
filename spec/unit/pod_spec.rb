require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../app/models/metrics', __FILE__)
require File.expand_path('../../../app/models/pod', __FILE__)

describe Pod do
  describe '.with_metrics' do
    before do
      @pod = Pod.create(:name => 'TestPod')
      @metrics = Metrics.create(
        :pod => @pod,
        :github_stars => 12
      )
    end
    it 'returns a combined model' do
      Pod.with_metrics.all.map { |pod| pod[:github_stars] }.should == [12]
    end
  end
  describe '.oldest' do
    before do
      Pod.create(:name => 'OldestPod').save
      Pod.create(:name => 'YoungerPod').save
      Pod.create(:name => 'YoungestPod').save
    end
    it 'returns the LRU X pods' do
      Pod.oldest(2).map(&:name).should == %w(OldestPod YoungerPod)
    end
  end
end
