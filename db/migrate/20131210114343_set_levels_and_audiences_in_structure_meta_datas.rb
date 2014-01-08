class SetLevelsAndAudiencesInStructureMetaDatas < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      structure.level_ids    = structure.plannings.collect(&:level_ids).flatten.sort.uniq.join(',')
      structure.audience_ids = structure.plannings.collect(&:audience_ids).flatten.sort.uniq.join(',')
      structure.save(validate: false)
    end
  end

  def down
  end
end
