class CreatePlacesSubjects < ActiveRecord::Migration
  def change
    create_table :places_subjects, id: false do |t|
      t.references :subject
      t.references :place
    end
    add_index :places_subjects, [:subject_id, :place_id]
  end
end
