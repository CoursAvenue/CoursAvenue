class AddUniqueIndexToReplyToken < ActiveRecord::Migration
  def change
    add_index :reply_tokens, :token, unique: true
  end
end
