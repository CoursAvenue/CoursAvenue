class AddCommentsSubjectsTable < ActiveRecord::Migration
  def change
    create_table :comments_subjects, :id => false do |t|
      t.references :comment, :subject
    end
    add_index :comments_subjects, [:comment_id, :subject_id]
  end
end
