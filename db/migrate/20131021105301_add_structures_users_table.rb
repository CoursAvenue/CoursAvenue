class AddStructuresUsersTable < ActiveRecord::Migration
  def change
    drop_table :plannings_users
    drop_table :courses_users
    drop_table :places_users

    create_table :structures_users, :id => false do |t|
      t.references :structure, :user
    end
    add_index :structures_users, [:structure_id, :user_id]

    create_table :subjects_users, :id => false do |t|
      t.references :user, :subject
    end
    add_index :subjects_users, [:user_id, :subject_id]

    add_column :users, :active, :boolean, default: true
  end
end
