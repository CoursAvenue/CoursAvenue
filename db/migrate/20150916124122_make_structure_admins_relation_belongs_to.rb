class MakeStructureAdminsRelationBelongsTo < ActiveRecord::Migration
  def change
    bar = ProgressBar.new(Admin.count)
    add_column :structures, :admin_id, :integer
    add_index :structures, :admin_id
    Admin.find_each do |admin|
      bar.increment!
      s = admin.structure
      next if s.nil?
      s.update_column :admin_id, admin.id
    end
    remove_column :admins, :structure_id
  end
end
