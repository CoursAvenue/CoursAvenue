class CreateCitiesSubjectsInfo < ActiveRecord::Migration
  def change
    create_table :city_subject_infos do |t|
      t.references :city
      t.references :subject

      t.text :title
      t.text :description

      t.timestamps
    end
  end
end
