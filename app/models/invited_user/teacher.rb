# When invitation are to teachers
class ::InvitedUser::Teacher < InvitedUser

  belongs_to :structure, foreign_key: :referrer_id

  # Tells if user is opt_in
  #
  # @return Boolean
  def email_opt_in?
    _email = self.email
    if admin = Admin.where(email: _email).first
      admin.email_opt_in?
    else
      true
    end
  end
end
