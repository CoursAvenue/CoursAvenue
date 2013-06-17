class AddSubjectsToStructure < ActiveRecord::Migration
  def change
    create_table :structures_subjects, :id => false do |t|
      t.references :structure, :subject
    end
    add_index :structures_subjects, [:structure_id, :subject_id]
  end
end
