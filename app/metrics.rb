class Metrics < Sequel::Model
  self.dataset = :metrics

  plugin :timestamps

  one_to_one :pod
end
