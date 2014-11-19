class CreateReplyTokens < ActiveRecord::Migration
  def change
    create_table :reply_tokens do |t|
      t.string :token
      t.string :reply_type
      t.hstore :data

      t.timestamps
    end
  end
end
