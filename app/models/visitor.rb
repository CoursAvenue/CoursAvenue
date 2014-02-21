class Visitor < ActiveRecord::Base
  validates :fingerprint, presence: true, uniqueness: true

  attr_accessible :address_name, :subject_id

  has_many :comments, class_name: "UnfinishedResource::Comment"

  def best(symbol)
    self[symbol].to_a.inject(["", 0]) { |memo, pair|
      k, v = pair

      memo = [k, v] if v.to_i > memo[1].to_i
      memo
    }
  end

  # determines whether the visitor has left multiple
  # comments on a single structure, something which
  # is not permitted
  #
  # @return true if and only if some of the visitors' published comments
  #   share their commentable_id
  def comment_collision?
    ids = self.comments.map(&:commentable_id)

    ids.uniq.length != ids.length
  end

  def address_name=(hash)
    @address_name ||= {}

    @address_name.merge! hash do |key, old, new|
      new + old.to_i
    end

    write_attribute(:address_name, @address_name)
  end

  def address_data
    self.address_name.to_a
  end

  def warnings
    warning_strings = []

    warning_strings << "Duplicate Comment" if self.comment_collision?

    warning_strings.empty?? ["None"] : warning_strings
  end

  def warnings?
    self.comment_collision?
  end
end
