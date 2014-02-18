class Visitor < ActiveRecord::Base
  validates :fingerprint, presence: true, uniqueness: true

  attr_accessible :address_name, :subject_id

  def best(symbol)
    self[symbol].to_a.inject(["", 0]) { |memo, pair|
      k, v = pair

      memo = [k, v] if v.to_i > memo[1].to_i
      memo
    }
  end
end
