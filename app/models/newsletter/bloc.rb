class Newsletter::Bloc < ActiveRecord::Base

  ######################################################################
  # Constants                                                          #
  ######################################################################

  BLOC_TYPES = ['Newsletter::Bloc::Text', 'Newsletter::Bloc::Image']

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :position, :type, :content, :remote_image_url, :image

  belongs_to :newsletter

  validates :type, presence: true
  validates :position, uniqueness: { scope: :newsletter_id }

  before_create :set_default_position

  mount_uploader :image, NewsletterImageUploader

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Duplicate this Newsletter Bloc model.
  #
  # @param bloc_owner: The owner of the new bloc. By default the current newsletter owner.
  #
  # @return The duplicated bloc.
  def duplicate!(bloc_owner = self.newsletter)
    duplicated_bloc = bloc_owner.blocs.build({
      position: self.position,
      type: self.type,
      content: self.content
    })

    if self.image?
      duplicated_bloc.remote_image_url = self.image.url
    end

    duplicated_bloc.save
    duplicated_bloc
  end

  private

  # Set the default position.
  #
  # @return self.
  def set_default_position
    if self.position.nil?
      self.position = newsletter.blocs.count + 1
    end
  end
end