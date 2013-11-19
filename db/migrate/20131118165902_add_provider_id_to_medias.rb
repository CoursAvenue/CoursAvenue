class AddProviderIdToMedias < ActiveRecord::Migration
  def up
    add_column :medias, :provider_id, :string
    add_column :medias, :provider_name, :string
    add_column :medias, :thumbnail_url, :text

    bar = ProgressBar.new(Media.videos.count)
    Media.videos.find_each do |media|
      bar.increment!
      media.send(:update_provider)
      media.send(:update_thumbnail)
    end
  end

  def down
    remove_column :medias, :provider_id
    remove_column :medias, :provider_name
    remove_column :medias, :thumbnail_url
  end
end
