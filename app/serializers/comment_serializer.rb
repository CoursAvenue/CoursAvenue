class CommentSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper

  attributes :id, :content, :title, :author_name, :course_name, :created_at, :rating, :distance_of_time

  has_one :reply, serializer: CommentReplySerializer

  def distance_of_time
    distance_of_time_in_words_to_now self.created_at
  end
end
