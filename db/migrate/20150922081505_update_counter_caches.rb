class UpdateCounterCaches < ActiveRecord::Migration
  def change
    bar = ProgressBar.new(Structure.count)
    Structure.find_each do |structure|
      bar.increment!
      Structure.reset_counters(structure.id, :comments)
    end
  end
end
