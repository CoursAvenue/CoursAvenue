class AddAssociatedConversationIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :associated_message_id, :integer
  end
end
