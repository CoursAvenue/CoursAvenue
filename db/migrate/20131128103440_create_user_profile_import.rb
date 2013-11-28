class CreateUserProfileImport < ActiveRecord::Migration
  def change
    create_table :user_profile_imports do |t|
      t.binary  :data,         null: false
      t.string  :filename
      t.string  :mime_type
      t.integer :structure_id

      t.timestamps
    end
  end
end
