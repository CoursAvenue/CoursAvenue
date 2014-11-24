class CreateFlyers < ActiveRecord::Migration
  def change
    create_table :flyers do |t|
      t.boolean :treated

      t.timestamps
    end
  end
end
