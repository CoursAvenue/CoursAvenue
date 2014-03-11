# When invitation are to students
class InvitedUser::Student < InvitedUser

  belongs_to :user, foreign_key: :referrer_id

  after_create :create_user_if_doesnt_exist

  # Tells if user is opt_in
  #
  # @return Boolean
  def email_opt_in?
    if user
      user.email_opt_in?
    else
      true
    end
  end

  def user
    _email = self.email
    User.where(email: _email).first
  end

  private

  def create_user_if_doesnt_exist
    if User.where(email: self.email).first.nil?
      u = User.new email: self.email
      u.save(validate: false)
    end
    nil
  end
end
