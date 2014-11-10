class AddSignUpAtForUsers < ActiveRecord::Migration
  def up
    add_column :users, :sign_up_at, :datetime
    User.all.each do |user|
      user.update_column :sign_up_at, user.created_at
    end
  end

  def down
    remove_column :users, :sign_up_at
  end
end
