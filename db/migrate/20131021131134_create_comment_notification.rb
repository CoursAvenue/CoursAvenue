class CreateCommentNotification < ActiveRecord::Migration
  def change
    create_table :comment_notifications do |t|
      t.references :user
      t.references :structure

      t.string :status
      t.timestamps
    end
    add_index :comment_notifications, :user_id
    add_index :comment_notifications, :structure_id
    add_index :comment_notifications, :status
  end
end
