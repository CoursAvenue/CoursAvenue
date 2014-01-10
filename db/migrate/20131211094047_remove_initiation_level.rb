class RemoveInitiationLevel < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Planning.where{level_ids =~ '%2%'}.count + Planning.where{level_ids =~ '%3%'}.count + Planning.where{level_ids =~ '%4%'}.count + Planning.where{level_ids =~ '%5%'}.count
    # Initiation (1) is removed and becomes beginner (2)
    # So All plannings that are beginner (2) becomes 1
    Planning.where{level_ids =~ '%2%'}.each do |planning|
      bar.increment!
      ids = planning.level_ids
      ids.delete(2)
      ids << 1
      planning.update_column :level_ids, ids.uniq.sort.join(',')
    end
    # 3 becomes 2, etc.
    Planning.where{level_ids =~ '%3%'}.each do |planning|
      bar.increment!
      ids = planning.level_ids
      ids.delete(3)
      ids << 2
      planning.update_column :level_ids, ids.uniq.sort.join(',')
    end
    Planning.where{level_ids =~ '%4%'}.each do |planning|
      bar.increment!
      ids = planning.level_ids
      ids.delete(4)
      ids << 3
      planning.update_column :level_ids, ids.uniq.sort.join(',')
    end
    Planning.where{level_ids =~ '%5%'}.each do |planning|
      bar.increment!
      ids = planning.level_ids
      ids.delete(5)
      ids << 4
      planning.update_column :level_ids, ids.uniq.sort.join(',')
    end
  end
end
