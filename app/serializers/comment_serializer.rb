class CommentSerializer < ActiveModel::Serializer
    attributes :id, :content, :title, :author_name

end
