class User::Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :structure
  belongs_to :indexable_card

  attr_accessible :structure, :user, :indexable_card

  validates :user,           presence: true
  validates :structure,      presence: true, unless: -> (favorite) { favorite.indexable_card_id.present? }
  validates :indexable_card, presence: true, unless: -> (favorite) { favorite.structure_id.present? }

  validates :structure_id,      uniqueness: { scope: :user_id }, allow_nil: true
  validates :indexable_card_id, uniqueness: { scope: :user_id }, allow_nil: true

  after_create :affect_tag_to_user_profile

  scope :structures, -> { where.not(structure_id: nil) }
  scope :cards,      -> { where.not(indexable_card_id: nil) }

  private

  def affect_tag_to_user_profile
    return if structure.nil?
    structure.create_or_update_user_profile_for_user(user, UserProfile::DEFAULT_TAGS[:following])
  end
end
