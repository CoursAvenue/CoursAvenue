class AddSubjectIdToVisitor < ActiveRecord::Migration
  def change
    add_column :visitors, :subject_id, :hstore
  end
end
