class Mailboxer::ConversationQuery
  def self.build(relation, structure, params = {})
    query = new(relation)

    # When the conversation lable is present we just select this label.
    if params[:conversation_label_id].present?
      query = query.with_label(params[:conversation_label_id].to_i)
    else
      # Otherwise, we select everything but the public questions.
      unless params[:read].present?
        query = query.without_label(Mailboxer::Label::PUBLIC_QUESTION.id)
      end
    end

    # Finally, depending on the read param, we filter by their read status.
    if params[:read].present?
      query = query.read_for(structure.admin)
    else
      query = query.unread_for(structure.admin)
    end

    query
  end

  def initialize(relation)
    @relation = relation
  end

  # Select the conversations with the specified label.
  #
  # @return an ActiveRecord_Relation.
  def with_label(label_id)
    @relation = @relation.where(mailboxer_label_id: label_id)
    self
  end

  # Select the conversations with the specified label.
  #
  # @return an ActiveRecord_Relation.
  def without_label(label_id)
    @relation = @relation.where.not(mailboxer_label_id: label_id)
    self
  end

  # The read conversations in the relation.
  # NOTE: This should be used last in the query building, as it returns an array and can't be
  # chained to an ActiveRecord query.
  #
  # @return An array of conversations.
  def read_for(recipient)
    @relation.reject { |conversation| conversation.is_unread?(recipient) }
  end

  # The unread conversations in the relation.
  # NOTE: This should be used last in the query building, as it returns an array and can't be
  # chained to an ActiveRecord query.
  #
  # @return An array of conversations.
  def unread_for(recipient)
    @relation.select { |conversation| conversation.is_unread?(recipient) }
  end
end
