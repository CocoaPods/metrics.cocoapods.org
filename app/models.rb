require File.expand_path '../models/github_pod_metrics', __FILE__
require File.expand_path '../models/cocoadocs_pod_metrics', __FILE__
require File.expand_path '../models/stats_metrics', __FILE__

require File.expand_path '../models/pod', __FILE__

Sequel::Model.plugin :update_or_create
