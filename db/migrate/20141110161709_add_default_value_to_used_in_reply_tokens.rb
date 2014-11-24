class AddDefaultValueToUsedInReplyTokens < ActiveRecord::Migration
  def up
    change_column_default :reply_tokens, :used, false
  end

  def down
    change_column_default :reply_tokens, :used, nil
  end
end
