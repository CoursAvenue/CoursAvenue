class ChangeStructuresUsersToUserProfile < ActiveRecord::Migration
  def change
    rename_table :structures_users, :user_profiles

    add_column :user_profiles, :id, :primary_key

    add_column :user_profiles, :email,        :string
    add_column :user_profiles, :first_name,   :string
    add_column :user_profiles, :last_name,    :string
    add_column :user_profiles, :birthdate,    :date
    add_column :user_profiles, :notes,        :text
    add_column :user_profiles, :phone,        :string
    add_column :user_profiles, :mobile_phone, :string
    add_column :user_profiles, :address,      :text
  end
end
