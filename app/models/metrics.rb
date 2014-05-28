class Metrics < Sequel::Model(:metrics)
  plugin :timestamps

  many_to_one :pod
end
