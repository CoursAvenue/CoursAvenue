class Comment < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :commentable, :commentable_id, :commentable_type, :content, :type

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :commentable, polymorphic: true, touch: true

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :content, :commentable, presence: true

end
