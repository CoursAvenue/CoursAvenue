class CreateDisciplines < ActiveRecord::Migration
  def change
    create_table :disciplines do |t|
      t.string :name
      t.string :short_name
      t.text   :info

      t.timestamps
    end
  end
end
