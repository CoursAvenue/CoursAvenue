class AddFieldsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name,  :string
    add_column :users, :zip_code,   :string

    bar = ProgressBar.new User.where{name != nil}.count
    User.where{name != nil}.find_each do |user|
      bar.increment!
      if user.name
        first_name, last_name = user.name.split(' ')
        user.update_column :first_name, first_name
        user.update_column :last_name, last_name
      end
    end
    remove_column :users, :name
  end

  def down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :zip_code

    add_column    :users, :name, :string
  end
end
