class CreateSmsLogger < ActiveRecord::Migration
  def change
    create_table :sms_loggers do |t|
      t.string  :number
      t.text    :text
      t.string  :sender_type
      t.integer :sender_id

      t.timestamps
    end
  end
end
