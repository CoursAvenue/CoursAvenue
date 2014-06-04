class FixProfileWithTwoMediaCover < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      next if structure.medias.count < 2
      if structure.medias.cover.count > 1
        if structure.medias.cover.videos.count > 0
          to_be_cover = structure.medias.cover.videos.first
        else
          to_be_cover = structure.medias.cover.first
        end
        structure.medias.cover.map{ |media| media.update_column :cover, false}
        to_be_cover.update_column :cover, true
      end
    end
  end
end
