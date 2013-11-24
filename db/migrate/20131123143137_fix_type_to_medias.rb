class FixTypeToMedias < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Media.count
    Media.find_each do |media|
      bar.increment!
      if media.format == 'video'
        media.update_column :type, 'Media::Video'
      elsif media.format == 'image'
        media.update_column :type, 'Media::Image'
      end
    end
  end
end
