class Newsletter::Bloc < ActiveRecord::Base

  ######################################################################
  # Constants                                                          #
  ######################################################################

  BLOC_TYPES = %w(text image)

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :position, :type, :content, :remote_image_url, :image

  belongs_to :newsletter

  validates :type, presence: true
  validates :position, uniqueness: { scope: :newsletter_id }

  before_create :set_default_position

  ######################################################################
  # Methods                                                            #
  ######################################################################

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
