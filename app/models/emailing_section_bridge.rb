class EmailingSectionBridge < ActiveRecord::Base

  attr_accessible :media_id

  belongs_to :structure
  belongs_to :emailing_section

  # Get the URL of the Media associated with this bridge.
  #
  # @return the String or nil
  def media_url
    if self.is_logo?
      self.structure.first.logo.url
    else
      media = Media.where(id: self.media_id).first
      if media.type == 'Media::Video'
        media.thumbnail_url
      else
        media.image.url
      end
    end
  end
end
