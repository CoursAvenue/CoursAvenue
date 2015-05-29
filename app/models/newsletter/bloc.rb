class Newsletter::Bloc < ActiveRecord::Base

  ######################################################################
  # Constants                                                          #
  ######################################################################

  BLOC_TYPES = ['Newsletter::Bloc::Text', 'Newsletter::Bloc::Image', 'Newsletter::Bloc::Multi']

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :position, :type, :content, :remote_image_url, :image

  belongs_to              :newsletter
  has_and_belongs_to_many :sub_blocs,
                          class_name: 'Newsletter::Bloc',
                          join_table: 'newsletter_bloc_ownerships',
                          foreign_key: :bloc_id,
                          association_foreign_key: :sub_bloc_id,
                          dependent: :destroy

  validates :type, presence: true

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
