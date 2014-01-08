# We want to disable the confirmation after user is created because User are
# created in UsersReminder when sending notifications
module Devise::Models::Confirmable
  def send_confirmation_notification?
    false
  end
end
