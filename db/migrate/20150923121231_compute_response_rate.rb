class ComputeResponseRate < ActiveRecord::Migration
  def up
    structures = Structure.where.not(admin_id: nil)
    bar = ProgressBar.new(structures.count)
    structures.find_each do |s|
      bar.increment!
      s.delay.compute_response_rate
    end
  end

  def down
  end
end
