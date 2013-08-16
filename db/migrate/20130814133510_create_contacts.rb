# -*- encoding : utf-8 -*-
class CreateContacts < ActiveRecord::Migration
  def up
    create_table :contacts do |t|
      t.references :contactable, :null => false, :polymorphic => true
      t.string     :type,        :null => false

      t.string     :name
      t.string     :phone
      t.string     :mobile_phone
      t.string     :email

      t.timestamps
    end

    add_index :contacts,  :contactable_id
    add_index :contacts, [:contactable_id, :type]
  end

  def down
    drop_table :contacts
  end
end
