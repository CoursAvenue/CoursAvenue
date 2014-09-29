class EmailingSectionBridge < ActiveRecord::Base

  attr_accessible :media_id

  belongs_to :structure
  belongs_to :emailing_section

  # Get the Media associated with this bridge.
  #
  # @return the Paperclip::Attachment of the media or nil.
  def media
    if self.is_logo
      Structure.where(id: self.structure).first.logo
    else
      Media.where(id: self.media_id).first.image
    end
  end
end
