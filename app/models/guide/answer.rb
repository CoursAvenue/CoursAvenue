class Guide::Answer < ActiveRecord::Base
  attr_accessible :content

  belongs_to :guide
  belongs_to :question, class_name: 'Guide::Question', foreign_key: 'guide_question_id'

  validates :content, presence: true
end
