class Following < ActiveRecord::Base
  belongs_to :user
  belongs_to :structure

  attr_accessible :structure, :user

  validates :structure, :user, presence: true
  validates :user_id, uniqueness: { scope: :structure_id }

  after_create :affect_tag_to_user_profile

  private

  def affect_tag_to_user_profile
    user_profile = UserProfile.where(UserProfile.arel_table[:structure_id].eq(self.structure.id).and(
                                     UserProfile.arel_table[:user_id].eq(self.user.id))).first
    return if user_profile.nil?
    user_profile.add_tags(UserProfile::DEFAULT_TAGS[:following])
  end
end
