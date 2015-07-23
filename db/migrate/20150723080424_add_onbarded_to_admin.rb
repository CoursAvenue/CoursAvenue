class AddOnbardedToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :onboarded, :boolean, default: false

    Admin.where.not(created_at: (1.day.ago..1.second.ago)).update_all(onboarded: true)
  end
end
