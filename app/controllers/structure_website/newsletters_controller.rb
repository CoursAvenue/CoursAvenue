class StructureWebsite::NewslettersController < StructureWebsiteController

  def unsubscribe
    if params[:md_email].present?
      if (user_profile = @structure.user_profiles.where(email: params[:md_email]).first)
        user_profile.subscribed = false
        user_profile.save
      end
    end
    redirect_to structure_website_planning_path, notice: 'Vous êtes bien désinscrit'
  end

end
