require File.expand_path '../models/github_metrics', __FILE__
require File.expand_path '../models/commit', __FILE__
require File.expand_path '../models/version', __FILE__
require File.expand_path '../models/pod', __FILE__

Sequel::Model.plugin :update_or_create