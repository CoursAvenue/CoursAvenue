class AddUsedToReplyToken < ActiveRecord::Migration
  def change
    add_column :reply_tokens, :used, :boolean
  end
end
