# encoding: utf-8
class Pro::NewsletterUsersController < Pro::ProController
  before_filter :authenticate_pro_admin!

  layout 'admin'

  authorize_resource :newsletter_user

  def index
    @newsletter_users = NewsletterUser.order('created_at DESC').all
  end
end
