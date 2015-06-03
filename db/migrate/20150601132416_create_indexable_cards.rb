class CreateIndexableCards < ActiveRecord::Migration
  def change
    create_table :indexable_cards do |t|
      t.references :structure, index: true
      t.references :subject, index: true
      t.references :place, index: true
      t.references :planning, index: true
      t.references :course, index: true

      t.timestamps
    end
  end
end
