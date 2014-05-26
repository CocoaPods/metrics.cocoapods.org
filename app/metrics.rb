class Metrics < Sequel::Model(:metrics)
  plugin :timestamps

  one_to_one :pod
end
