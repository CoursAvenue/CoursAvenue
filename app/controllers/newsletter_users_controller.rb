class NewsletterUsersController < InheritedResources::Base
  actions :create

  def create
    create! do |format|
      if @newsletter_user.errors.empty?
        flash[:notice] = t('newsletter_users.creation_success_notice')
      else
        flash[:error] = t('newsletter_users.wrong_email')
      end
      format.html { redirect_to root_url }
    end
  end
end
