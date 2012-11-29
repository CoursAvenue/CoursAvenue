class CreateAudiences < ActiveRecord::Migration
  def change
    create_table :audiences do |t|
      t.string  :name
      t.integer :order

      t.timestamps
    end
  end
end
