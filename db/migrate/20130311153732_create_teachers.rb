class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |t|
      t.string :name
      t.integer :admin_id
      t.integer :structure_id

      t.timestamps
    end
  end
end
