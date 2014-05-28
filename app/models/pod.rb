require 'lib/metrics'

# Only for reading purposes.
#
class Pod < Sequel::Model(:pods)
  include Metrics

  plugin :timestamps

  # E.g. Pod.oldest(2)
  #
  def self.oldest(amount = 100)
    order(:updated_at).limit(amount)
  end
end
