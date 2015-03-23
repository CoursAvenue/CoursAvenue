class CreateBlogSubscribers < ActiveRecord::Migration
  def change
    create_table :blog_subscribers do |t|
      t.string :email
      t.integer :user_id
      t.string :type

      t.timestamps
    end
  end
end
