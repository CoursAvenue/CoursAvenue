class MergeFirstAndLastNameForUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    bar = ProgressBar.new User.count
    User.find_each do |user|
      bar.increment!
      user.update_column :name, "#{user.first_name} #{user.last_name}"
    end
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
