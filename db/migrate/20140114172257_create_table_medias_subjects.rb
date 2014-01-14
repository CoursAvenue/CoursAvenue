class CreateTableMediasSubjects < ActiveRecord::Migration
  def change
    create_table :medias_subjects, id: false do |t|
      t.references :subject
      t.references :media
    end
  end
end
