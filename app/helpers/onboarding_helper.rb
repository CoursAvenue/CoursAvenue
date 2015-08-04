module OnboardingHelper
  def admin_current_onboarding_step(structure)
    if !structure.profile_completed?
      link_to edit_pro_structure_path(structure), data: { onboarding_step: true } do
        "<i class='fa fa-square-o' data-square='true'></i>".html_safe +
          ' Ajoutez votre description et votre logo'
      end
    elsif structure.comments.empty? and structure.comment_notifications.empty?
      link_to recommendations_pro_structure_path(structure), data: { onboarding_step: true } do
        "<i class='fa fa-square-o' data-square='true'></i>".html_safe +
          ' Boostez votre bouche-à-oreille'
      end
    elsif structure.medias.empty?
      link_to pro_structure_medias_path(structure), data: { onboarding_step: true } do
        "<i class='fa fa-square-o' data-square='true'></i>".html_safe +
          ' Ajoutez vos photos et vidéos'
      end
    elsif structure.plannings.future.any?
      link_to pro_structure_courses_path(structure), data: { onboarding_step: true } do
        "<i class='fa fa-square-o' data-square='true'></i>".html_safe +
          ' Mettez à jour votre planning'
      end
    else
      ''
    end
  end

  def admin_current_onboarding_percentage(structure)
    status = 100
    status -= 25 if !structure.profile_completed?
    status -= 25 if structure.medias.select(&:persisted?).empty?
    status -= 25 if structure.comments.select(&:persisted?).empty?
    status -= 25 if structure.plannings.future.select(&:persisted?).empty?

    status
  end
end
