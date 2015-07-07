class Guide::Question < ActiveRecord::Base
  belongs_to :guide

  validates :content, presence: true
  validates :ponderation, presence: true
end
