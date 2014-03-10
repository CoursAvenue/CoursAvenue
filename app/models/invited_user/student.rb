class InvitedUser::Student < InvitedUser

  belongs_to :user, foreign_key: :referrer_id

  # Tells if user is opt_in
  #
  # @return Boolean
  def email_opt_in?
    _email = self.email
    if user = User.where(email: _email).first
      user.email_opt_in?
    else
      true
    end
  end
end
