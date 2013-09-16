class AddIndexToStudents < ActiveRecord::Migration
  def change
    add_index :students, :structure_id
  end
end
