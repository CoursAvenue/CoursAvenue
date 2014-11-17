# encoding: utf-8
class UserMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  helper :prices, :comments, :structures, :mailer

  default from: "\"L'équipe CoursAvenue\" <contact@coursavenue.com>"

  # Monday email to push the user to fill passions
  def subscribed_to_newsletter(user)
    @user    = user
    mail to: @user.email, subject: "Votre inscription à la newsletter de CoursAvenue.com"
  end

  ######################################################################
  # Email reminder                                                     #
  ######################################################################
  # Monday email to push the user to fill passions
  def monday_jpo(user)
    @user    = user
    mail to: @user.email, subject: "Vous êtes sur Paris les 5-6 avril ? Participez à l'un des 5 000 cours gratuits"
  end

  # Monday email to push the user to fill passions
  def passions_incomplete(user)
    @user    = user
    mail to: @user.email, subject: 'Renseignez toutes vos passions sur votre profil'
  end

  # Email sent to the team when a user send a contact message
  def contact(name, email, content)
    @name    = name
    @email   = email
    @content = content
    mail to: 'contact@coursavenue.com', subject: 'Suite de votre message sur CoursAvenue', reply_to: email
  end

  # Welcomes the user on the platforme
  def welcome(user)
    @user = user
    mail to: @user.email, subject: 'Bienvenue sur CoursAvenue.com'
  end

  # Inform the user that the comment has correctly been submitted
  # When the user was invited before through a comment notification
  def congratulate_for_accepted_comment(comment)
    @comment   = comment
    @user      = comment.user
    @structure = @comment.structure
    mail to: @comment.email, subject: "Votre avis à propos de : #{@structure.name}", template_name: 'congratulate_for_comment'
  end

  # Inform the user that the comment has correctly been submitted
  def congratulate_for_comment(comment)
    @comment   = comment
    @user      = comment.user
    @structure = @comment.structure
    mail to: @comment.email, subject: "Votre avis à propos de : #{@structure.name}", template_name: 'congratulate_for_comment'
  end

  # Inform the user that the comment has been validated by the teacher
  def comment_has_been_validated(comment)
    @comment   = comment
    @user      = comment.user
    @structure = @comment.structure
    mail to: @comment.email, subject: "Votre avis est maintenant visible"
  end

  # Inform the user that the comment has been validated by the teacher
  def comment_anniversary(comment)
    @comment   = comment
    @user      = comment.user
    @structure = @comment.structure
    mail to: @comment.email, subject: "Un an déjà... bon anniversaire !"
  end

  def suggest_other_structures(user, structure)
    @user       = user
    @structure  = structure
    @subject    = structure.dominant_root_subject
    @city       = structure.dominant_city
    mail to: @user.email, subject: "Alternatives à #{structure.name}"
  end

  def emailing(emailing, to='contact@coursavenue.com')
    @emailing = emailing
    mail to: to, subject: '[Newsletter] Previsualisation'
  end

  def monthly_newsletter(user)
    @user       = user
    @city       = user.city || City.find('paris')
    @dance_structures   = @user.around_structures_all_subjects(3, { nb_courses: 1, root_subject_id: 'danse', subject_id: 'danse', medias_count: 1 })
    @dance_structures   = @dance_structures.sort_by{ |a| (a.premium? ? 0 : 1) }
    @theatre_structures = @user.around_structures_all_subjects(3, { nb_courses: 1, root_subject_id: 'theatre-scene', subject_id: 'theatre-scene', medias_count: 1, without_ids: @dance_structures.map(&:id) })
    @theatre_structures = @theatre_structures.sort_by{ |a| (a.premium? ? 0 : 1) }
    @arts_structures    = @user.around_structures_all_subjects(3, { nb_courses: 1, root_subject_id: 'dessin-peinture-arts-plastiques', subject_id: 'dessin-peinture-arts-plastiques', medias_count: 1, without_ids: @dance_structures.map(&:id) + @theatre_structures.map(&:id) })
    @arts_structures    = @arts_structures.sort_by{ |a| (a.premium? ? 0 : 1) }
    @yoga_structures    = @user.around_structures_all_subjects(3, { nb_courses: 1, root_subject_id: 'yoga-bien-etre-sante', subject_id: 'yoga-bien-etre-sante', medias_count: 1, without_ids: @dance_structures.map(&:id) + @theatre_structures.map(&:id) + @arts_structures.map(&:id) })
    @yoga_structures    = @yoga_structures.sort_by{ |a| (a.premium? ? 0 : 1) }
    @other              = @user.around_structures_all_subjects(6, { nb_courses: 1, medias_count: 1, without_ids: @dance_structures.map(&:id) + @theatre_structures.map(&:id) + @yoga_structures.map(&:id) + @arts_structures.map(&:id) }, 2)
    @other              = @other.sort_by{ |a| (a.premium? ? 0 : 1) }
    mail to: @user.email, subject: "☀ Cette année, vivez passionnément à #{@city.name}", from: "\"L'équipe CoursAvenue\" <news@coursavenue.com>"
  end

  ######################################################################
  # For inactive users                                                 #
  ######################################################################

  ######################################################################
  # For comments                                                       #
  ######################################################################
  def ask_for_recommandations(comment_notification)
    return if comment_notification.complete?
    @structure  = comment_notification.structure
    @email      = comment_notification.user.email
    @user       = comment_notification.user
    @email_text = comment_notification.text
    @comment    = @structure.comments.build
    mail to: @email, subject: get_comment_notification_subject(comment_notification), template_name: get_comment_notification_template(comment_notification)
  end

  def ask_for_recommandations_stage_1(comment_notification)
    return if comment_notification.complete?
    @structure = comment_notification.structure
    @email     = comment_notification.user.email
    @user      = comment_notification.user
    mail to: @email, subject: get_comment_notification_subject(comment_notification), template_name: get_comment_notification_template(comment_notification)
  end

  def ask_for_recommandations_stage_2(comment_notification)
    return if comment_notification.complete?
    @structure = comment_notification.structure
    @email     = comment_notification.user.email
    @user      = comment_notification.user
    mail to: @email, subject: get_comment_notification_subject(comment_notification), template_name: get_comment_notification_template(comment_notification)
  end

  def ask_for_recommandations_stage_3(comment_notification)
    return if comment_notification.complete?
    @structure = comment_notification.structure
    @email     = comment_notification.user.email
    @user      = comment_notification.user
    mail to: @email, subject: get_comment_notification_subject(comment_notification), template_name: get_comment_notification_template(comment_notification)
  end

  def five_days_to_come_for_jpo(user)
    @user = user
    mail to: @user.email, subject: "Plus que 4 jours avant les Portes Ouvertes : n’attendez pas pour vous inscrire"
  end

  # Send an email with a sponsorship link.
  #
  # @param user — The sponsor.
  # @param sponsor_user — The email of the user sponsored.
  # @param promo_code_url — The Sponsorship's promo code url
  # @param text — The text of the email.
  def sponsor_user(user, sponsored_email, promo_code_url, text)
    @user           = user
    @text           = text
    @promo_code_url = promo_code_url
    mail to: sponsored_email, subject: "#{@user.name} vous invite au Pass Découverte"
  end

  private

  def get_comment_notification_template(comment_notification)
    case comment_notification.status
    when nil
      if comment_notification.notification_for.nil?
        template = 'ask_for_recommandations'
      else
        template = "ask_for_recommandations_for_#{comment_notification.notification_for}"
      end
    when 'resend_stage_1'
      if comment_notification.notification_for.nil?
        template = 'ask_for_recommandations_stage_1'
      else
        template = "ask_for_recommandations_stage_1_for_#{comment_notification.notification_for}"
      end
    when 'resend_stage_2'
      if comment_notification.notification_for.nil?
        template = 'ask_for_recommandations_stage_2'
      else
        template = "ask_for_recommandations_stage_2_for_#{comment_notification.notification_for}"
      end
    when 'resend_stage_3'
      if comment_notification.notification_for.nil?
        template = 'ask_for_recommandations_stage_3'
      else
        template = "ask_for_recommandations_stage_3_for_#{comment_notification.notification_for}"
      end
    end
    template
  end

  def get_comment_notification_subject(comment_notification)
    case comment_notification.status
    when nil
      if comment_notification.notification_for.nil?
        "#{comment_notification.structure.name} vous demande une recommandation"
      else
        "Merci de laisser un avis à propos de vos ateliers Portes Ouvertes"
      end
    when 'resend_stage_1'
      if comment_notification.notification_for.nil?
        "Votre opinion sur #{comment_notification.structure.name}"
      else
        "Qu'avez-vous pensé de vos ateliers Portes Ouvertes ?"
      end
    when 'resend_stage_2'
      if comment_notification.notification_for.nil?
        "#{comment_notification.structure.name} vous demande une recommandation"
      else
        "Partagez votre expérience sur les Portes Ouvertes des 5-6 avril 2014"
      end
    when 'resend_stage_3'
      if comment_notification.notification_for.nil?
        "Dernier jour pour recommander #{comment_notification.structure.name}"
      else
        "Partagez votre expérience sur les Portes Ouvertes des 5-6 avril 2014"
      end
    end
  end

end
