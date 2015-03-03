class UserReminder
  # Send a reminder depending on the email status of the user.
  #
  # @param user The User to send the reminder to
  #
  # @return nil
  def self.status(user)
    return if user.email_status.nil? or !user.email_passions_opt_in?
    return if user.update_email_status.nil?

    user.update_last_email_sent_status!(user.email_status)
    UserMailer.delay.send(user.email_status.to_sym, self)
  end
end
