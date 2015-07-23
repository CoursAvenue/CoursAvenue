class EmailingSectionBridge < ActiveRecord::Base

  attr_accessible :media_id, :is_logo,
                  :subject_id, :subject_name,
                  :review_id, :review_text, :review_custom,
                  :city_text

  belongs_to :structure
  belongs_to :indexable_card

  belongs_to :emailing_section

  # Get the URL of the Media associated with this bridge.
  #
  # @return the String or nil
  def media_url
    if self.is_logo?
      self.structure.logo.url(:thumbnail_email_cropped)
    else
      media = Media.where(id: self.media_id).first
      return if media.nil?
      if media.type == 'Media::Video'
        media.thumbnail_url
      else
        media.image.url(:thumbnail_email_cropped)
      end
    end
  end
end
