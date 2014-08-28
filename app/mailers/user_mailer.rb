# encoding: utf-8
class UserMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  helper :prices, :comments

  default from: "\"L'équipe CoursAvenue\" <contact@coursavenue.com>"


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
    @structure = @comment.structure
    mail to: @comment.email, subject: "Votre avis à été validé !"
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
