class NewslettersController < ApplicationController

  def unsubscribe
    if params[:md_email].present?
      user_profile = @structure.user_profile.where(email: params[:md_email]).first
      user_profile.subscribed = false
      user_profile.save
    end
    redirect_to structure_website_planning_path, notice: 'Vous êtes bien désinscrit'
  end

end
