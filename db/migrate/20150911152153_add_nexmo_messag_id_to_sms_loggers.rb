class AddNexmoMessagIdToSmsLoggers < ActiveRecord::Migration
  def change
    add_column :sms_loggers, :nexmo_message_id, :string
  end
end
