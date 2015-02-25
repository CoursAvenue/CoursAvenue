class CreateCallReminders < ActiveRecord::Migration
  def change
    create_table :call_reminders do |t|
      t.string :name
      t.string :phone_number
      t.string :website
      t.string :status
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
