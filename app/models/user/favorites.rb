class User::Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :structure
  belongs_to :indexable_card

  attr_accessible :structure, :user

  validates :structure, :user, presence: true
  validates :user_id, uniqueness: { scope: :structure_id }

  after_create :affect_tag_to_user_profile

  private

  def affect_tag_to_user_profile
    structure.create_or_update_user_profile_for_user(user, UserProfile::DEFAULT_TAGS[:following])
  end
end
