# -*- encoding : utf-8 -*-
class CreateContacts < ActiveRecord::Migration
  def up
    create_table :contacts do |t|
      t.references :contactable, :null => false, :polymorphic => true

      t.string     :name
      t.string     :phone
      t.string     :mobile_phone
      t.string     :email

      t.timestamps
    end
  end

  def down
    drop_table :contacts
  end
end
