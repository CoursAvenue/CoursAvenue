class CreateEmailings < ActiveRecord::Migration
  def change
    create_table :emailings do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
