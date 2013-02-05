class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :name
      t.text   :info

      t.timestamps
    end

    add_column :subjects, :slug, :string
    add_index  :subjects, :slug, unique: true
  end
end
