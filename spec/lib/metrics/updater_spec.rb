require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../app/models', __FILE__)
require File.expand_path('../../../../lib/metrics/github', __FILE__)
require File.expand_path('../../../../lib/metrics/updater', __FILE__)

describe Metrics::Updater do

  describe 'find_pods_without_github_metrics' do
    describe 'pods without metrics' do
      before do
        @pod = Pod.create(:name => 'PodNoMetrics')
      end
      it 'finds them' do
        Metrics::Updater.find_pods_without_github_metrics.map(&:id).should == [@pod.id]
      end
    end
  end

  describe 'find_pods_with_old_github_metrics' do
    describe 'pods without metrics' do
      before do
        @pod = Pod.create(:name => 'PodNoMetrics')
        GithubMetrics.create(:pod_id => @pod.id, :updated_at => Date.today - 4)
      end
      it 'finds them' do
        Metrics::Updater.find_pods_with_old_github_metrics.map(&:id).should == [@pod.id]
      end
    end

    describe 'pods with old and low not_found metrics' do
      before do
        @pod = Pod.create(:name => 'PodNoMetrics')
        GithubMetrics.create(:pod_id => @pod.id, :updated_at => Date.today - 2, :not_found => 1)
      end
      it 'finds them' do
        Metrics::Updater.find_pods_with_old_github_metrics.map(&:id).should == [@pod.id]
      end
    end

    describe 'pods with old and high not_found metrics' do
      before do
        @pod = Pod.create(:name => 'PodNoMetrics')
        GithubMetrics.create(:pod_id => @pod.id, :updated_at => Date.today - 2, :not_found => 3)
      end
      it 'finds them' do
        Metrics::Updater.find_pods_with_old_github_metrics.map(&:id).should == []
      end
    end
  end

end
