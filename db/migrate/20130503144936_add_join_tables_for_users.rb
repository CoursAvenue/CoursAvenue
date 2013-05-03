class AddJoinTablesForUsers < ActiveRecord::Migration
  def change
    create_table :places_users, :id => false do |t|
      t.references :place, :user
    end
    add_index :places_users, [:place_id, :user_id]

    create_table :courses_users, :id => false do |t|
      t.references :course, :user
    end
    add_index :courses_users, [:course_id, :user_id]

    create_table :plannings_users, :id => false do |t|
      t.references :user, :planning
    end
    add_index :plannings_users, [:planning_id, :user_id]
  end
end
