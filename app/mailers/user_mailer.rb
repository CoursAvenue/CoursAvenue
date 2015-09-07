# encoding: utf-8
class UserMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic
  include ::Concerns::FormMailer

  layout 'email'

  helper :application, :prices, :comments, :structures

  default from: "\"L'équipe CoursAvenue\" <contact@coursavenue.com>"

  def subscribed_to_newsletter(user)
    @user    = user
    mail to: @user.email, subject: "Votre inscription à la newsletter de CoursAvenue.com"
  end

  ######################################################################
  # Email reminder                                                     #
  ######################################################################

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
    return if comment.user.nil?
    return unless comment.user.email_newsletter_opt_in
    @comment   = comment
    @user      = comment.user
    @structure = @comment.structure
    mail to: @comment.email, subject: "Un an déjà... bon anniversaire !"
  end

  def emailing(emailing, to='contact@coursavenue.com')
    @emailing = emailing
    mail to: to, subject: '[Newsletter] Previsualisation'
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
    @comment   = @structure.comments.build
    mail to: @email, subject: get_comment_notification_subject(comment_notification), template_name: get_comment_notification_template(comment_notification)
  end

  def ask_for_recommandations_stage_2(comment_notification)
    return if comment_notification.complete?
    @structure = comment_notification.structure
    @email     = comment_notification.user.email
    @user      = comment_notification.user
    @comment   = @structure.comments.build
    mail to: @email, subject: get_comment_notification_subject(comment_notification), template_name: get_comment_notification_template(comment_notification)
  end

  def ask_for_recommandations_stage_3(comment_notification)
    return if comment_notification.complete?
    @structure = comment_notification.structure
    @email     = comment_notification.user.email
    @user      = comment_notification.user
    @comment   = @structure.comments.build
    mail to: @email, subject: get_comment_notification_subject(comment_notification), template_name: get_comment_notification_template(comment_notification)
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

  ######################################################################
  # Blog                                                               #
  ######################################################################

  # When user subscribe to newsletter blog
  def subscribed_to_blog(user)
    @user = user
    mail to: @user.email, subject: "Bienvenue sur la newsletter CoursAvenue"
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
