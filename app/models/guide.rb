class Guide < ActiveRecord::Base
  has_many :questions, class_name: 'Guide::Question'
  has_many :answers,   class_name: 'Guide::Answer'

  validates :title,       presence: true
  validates :description, presence: true
end
