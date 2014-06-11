require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../app/models/github_pod_metrics', __FILE__)
require File.expand_path('../../../../app/models/pod', __FILE__)

describe Pod do

  describe '#specification_json' do
    before do
      @pod = Pod.create(:name => 'TestPod1')
      version = @pod.add_version(:name => '1.10.0')
      version.add_commit(:sha => 'shalalalala', :committer_id => 1, :specification_data => '1.10.0')
      version = @pod.add_version(:name => '1.9.0')
      version.add_commit(:sha => 'shalalalala', :committer_id => 1, :specification_data => '1.9.0')
    end
    it 'returns the data of the last version' do
      @pod.specification_json.should == '1.10.0'
    end
  end

  describe '.with_github_pod_metrics' do
    before do
      @pod = Pod.create(:name => 'TestPod1')
      @metrics = GithubPodMetrics.create(
        :pod => @pod,
        :stargazers => 12,
        :open_pull_requests => 1
      )
      @pod = Pod.create(:name => 'TestPod2')
      @metrics = GithubPodMetrics.create(
        :pod => @pod,
        :stargazers => 1001,
        :open_pull_requests => 23
      )
    end
    it 'returns a combined model' do
      result = Pod.with_github_pod_metrics.all
      result.map(&:github_pod_stargazers).should == [12, 1001]
      result.map(&:github_pod_open_pull_requests).should == [1, 23]
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

  describe '.without_github_pod_metrics' do
    describe 'with some github metrics' do
      before do
        Pod.create(:name => 'PodWithout1')
        Pod.create(:name => 'PodWithout2')
        metrics_pod = Pod.create(:name => 'PodWith')
        GithubPodMetrics.create(:pod => metrics_pod)
      end
      it 'returns the pods without github metrics' do
        Pod.without_github_pod_metrics.all.map(&:name).should == %w(PodWithout1 PodWithout2)
      end
    end
    describe 'without github metrics' do
      before do
        Pod.create(:name => 'PodWithout1')
        Pod.create(:name => 'PodWithout2')
        Pod.create(:name => 'PodWithout3')
      end
      it 'returns the least recently updated X pods' do
        Pod.without_github_pod_metrics.all.map(&:name).should == %w(PodWithout1 PodWithout2 PodWithout3)
      end
    end
  end

  describe '.with_old_github_pod_metrics' do
    before do
      metrics_pod = Pod.create(:name => 'PodWith1')
      GithubPodMetrics.create(:pod => metrics_pod, :updated_at => Date.today)
      metrics_pod = Pod.create(:name => 'PodWith2')
      GithubPodMetrics.create(:pod => metrics_pod, :updated_at => Date.parse('2013-12-12'))
    end
    it 'returns the least recently updated X pods' do
      Pod.with_old_github_pod_metrics.all.map(&:name).should == %w(PodWith2)
    end
  end

  describe '#github_url' do
    before do
      @pod = Pod.create(:name => 'TestPod1')
    end
    describe 'Non-.git extension' do
      before do
        @pod.expects(:specification_data).once.returns(
          'source' => {
            'git' => 'https://github.com/mystcolor/JTAttributedLabel'
          }
        )
      end
      it 'extracts the github_url correctly' do
        @pod.github_url.should == 'https://github.com/mystcolor/JTAttributedLabel'
      end
    end
  end

end
