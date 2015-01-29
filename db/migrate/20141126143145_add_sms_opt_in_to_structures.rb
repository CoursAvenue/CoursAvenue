class AddSmsOptInToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :sms_opt_in, :boolean, default: false
  end
end
