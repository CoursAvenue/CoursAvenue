class AddAncestryDepthToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :ancestry_depth, :integer, :default => 0
    add_index  :subjects, :ancestry_depth
    Subject.rebuild_depth_cache!
  end
end
