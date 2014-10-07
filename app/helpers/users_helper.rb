# encoding: utf-8
module UsersHelper

  # Creates a URL to a Facebook Send Dialog.
  # More information: <https://developers.facebook.com/docs/sharing/reference/send-dialog>
  #
  # @param user      — The User sending the message.
  # @param friend_id — The friend Facebook ID.
  #
  # @return The Send Dialog URL String.
  def share_sponsorship_request_to_facebook_friend_url(user, friend_id)
    link = user.sponsorship_slug
    redirect_uri = user.sponsorship_slug
    URI.encode("http://www.facebook.com/dialog/send?app_id=#{CoursAvenue::Application::FACEBOOK_APP_ID}&link=#{link}&redirect_uri=#{redirect_uri}&to=#{friend_id}")
  end

  def facebook_friends user

  end
end
