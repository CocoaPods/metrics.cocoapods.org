class Metrics < Sequel::Model
  self.dataset = :metrics

  one_to_one :pod
end
