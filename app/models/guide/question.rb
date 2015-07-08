class Guide::Question < ActiveRecord::Base
  belongs_to :guide
  has_many :answers, class_name: 'Guide::Answer', foreign_key: 'guide_question_id'

  validates :content, presence: true
  validates :ponderation, presence: true
end
