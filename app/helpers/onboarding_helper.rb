module OnboardingHelper
  def admin_current_onboarding_step(structure)
    if !structure.profile_completed?
      link_to edit_pro_structure_path(structure) do
        "<i class='fa fa-square-o'></i>".html_safe +
          ' Compléter mes informations générales et ajouter un logo'
      end
    elsif structure.comments.empty? and structure.comment_notifications.empty?
      link_to recommendations_pro_structure_path(structure) do
        "<i class='fa fa-square-o'></i>".html_safe +
          ' Demander des recommandations à mes élèves'
      end
    elsif structure.medias.empty?
      link_to pro_structure_medias_path(structure) do
        "<i class='fa fa-square-o'></i>".html_safe +
          ' Mettre en ligne les photos et vidéos de mes cours'
      end
    elsif structure.plannings.future.any?
      link_to pro_structure_courses_path(structure) do
        "<i class='fa fa-square-o'></i>".html_safe +
          ' Renseigner mes cours et mon planning'
      end
    else
      ''
    end
  end

  def admin_current_onboarding_percentage(structure)
    status = 100
    status -= 25 if !structure.profile_completed?
    status -= 25 if structure.medias.empty?
    status -= 25 if structure.comments.empty?
    status -= 25 if structure.plannings.future.empty?

    status
  end
end
