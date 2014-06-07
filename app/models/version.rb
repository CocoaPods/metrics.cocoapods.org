# Only for reading purposes.
#
class Version < Sequel::Model(:pod_versions)
  one_to_many :commits, :key => :pod_version_id
end
