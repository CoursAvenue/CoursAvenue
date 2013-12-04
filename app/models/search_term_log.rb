class SearchTermLog < ActiveRecord::Base
  attr_accessible :name

  before_save :decode_name

  private

  def decode_name
    self.name = URI::decode(name).strip
  end
end
