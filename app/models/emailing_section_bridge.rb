class EmailingSectionBridge < ActiveRecord::Base

  attr_accessible :media_id

  belongs_to :structure
  belongs_to :emailing_section

  # Get the Media associated with this bridge.
  #
  # @return the Media or nil
  def media
    Media.where(id: self.media_id).first
  end
end
