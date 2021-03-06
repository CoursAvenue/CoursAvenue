# encoding: utf-8
class AdminMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'
  helper :application, :structures

  default from: 'CoursAvenue <hello@coursavenue.com>'

  def hello_asso(email)
    mail to: email,
         subject: "Une grande nouvelle : CoursAvenue rejoint HelloAsso",
         from: 'CoursAvenue <contact@coursavenue.com>'
  end

  def the_end(structure)
    @structure = structure
    mail to: @structure.admin.email,
         subject: "C'est la fin du site CoursAvenue",
         from: 'CoursAvenue <contact@coursavenue.com>'
  end

  def all_comments(structure)
    @structure = structure
    @comments  = structure.comments
    return if @comments.empty?
    mail to: @structure.admin.email,
         subject: 'Tous vos avis CoursAvenue',
         from: 'CoursAvenue <contact@coursavenue.com>'
  end

 ######################################################################
  # For premium users                                                  #
  ######################################################################
  def commercial_email_2
    mail to: "adz@azd.az", subject: 'Votre profil Premium est activé'
  end

  def commercial_email(structure)
    return
    @structure = structure
    # mail to: @structure.admin.email,
    #      subject: "★ Dernier jour à -50%",
    #      from: "L'équipe CoursAvenue <contact@coursavenue.com>"
  end

  def subscription_renewal_failed(structure)
    @structure = structure
    mail to: @structure.admin.email,
         subject: 'Il y a un problème avec votre abonnement CoursAvenue',
         from: 'CoursAvenue Premium <premium@coursavenue.com>'
  end

  def your_premium_account_has_been_activated(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    mail to: @structure.admin.email,
         subject: 'Votre profil Premium est activé',
         from: 'CoursAvenue Premium <premium@coursavenue.com>'
  end

  def subscription_has_been_renewed(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    @similar_profiles  = @structure.similar_profiles(2)
    mail to: @structure.admin.email,
         subject: 'Votre profil Premium a été renouvelé',
         from: 'CoursAvenue Premium <premium@coursavenue.com>'
  end

  def subscription_has_been_canceled(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    mail to: @structure.admin.email,
         subject: 'Résiliation de votre profil Premium'
  end

  def subscription_has_been_reactivated(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    mail to: @structure.admin.email,
         subject: 'Votre réabonnement au Premium a bien été pris en compte'
  end

  def premium_follow_up_with_promo_code structure, monthyl_promo_code, annual_promo_code
    return if annual_promo_code.nil? or monthyl_promo_code.nil?
    @structure          = structure
    @monthly_promo_code = monthyl_promo_code
    @annual_promo_code  = annual_promo_code
    mail to: @structure.admin.email, subject: "Que s'est-il passé ?"
  end

  def user_is_now_following_you(structure, user)
    return if structure.admin.nil?
    @structure        = structure
    @user             = user
    @similar_profiles = @structure.similar_profiles(2)
    mail to: @structure.admin.email, subject: "Votre profil vient d'être ajouté en favori"
  end

  def message_information_reminder_1(conversation, admin)
    @conversation = conversation
    @message      = conversation.messages.first
    @admin        = admin
    @structure    = admin.structure
    @user         = conversation.recipients.select{|recipient| recipient.is_a? User }.first
    mail to: @admin.email,
         subject: "Rappel : demande d'information - #{@user.name}",
         reply_to: generate_reply_to('admin')
  end

  def message_information_reminder_2(conversation, admin)
    @conversation = conversation
    @message      = conversation.messages.first
    @admin        = admin
    @structure    = admin.structure
    @user         = conversation.recipients.select{|recipient| recipient.is_a? User }.first
    mail to: @admin.email,
         subject: "Rappel : demande d'information - #{@user.name}",
         reply_to: generate_reply_to('admin')
  end

  ######################################################################
  # Stickers                                                           #
  ######################################################################
  def stickers_has_been_ordered(sticker_demand)
    @structure = sticker_demand.structure
    mail to: @structure.admin.email, subject: 'Votre commande d’autocollants a bien été prise en compte'
  end

  def stickers_has_been_sent(sticker_demand)
    @structure = sticker_demand.structure
    mail to: @structure.admin.email, subject: "Vos autocollants viennent d'être expédiés"
  end

  ######################################################################
  # Recommandations                                                    #
  ######################################################################
  # Inform teacher that a students has commented his establishment
  def congratulate_for_accepted_comment(comment)
    @comment   = comment
    @structure = @comment.structure
    @admin     = @structure.admin
    @conversation = @comment
    mail to: @comment.commentable.contact_email,
      subject: "Vous avez reçu un avis de #{@comment.author_name}",
      reply_to: generate_reply_to('admin', 'comment')
  end

  def congratulate_for_comment(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: @comment.commentable.contact_email, subject: "Vous avez reçu un avis de #{@comment.author_name}"
  end

  def recommandation_has_been_recovered(structure, deletion_reason)
    @structure          = structure
    deletion_reason_key = deletion_reason.split('.').last
    @email_text         = I18n.t("comments.recover_email_texts.#{deletion_reason_key}")
    mail to: @structure.admin.email, subject: "Votre demande de modification d'avis a bien été prise en compte"
  end

  ######################################################################
  # The End                                                            #
  ######################################################################

  def you_have_control_of_your_account(structure)
    @structure        = structure
    mail to: structure.admin.email,
         subject: "Votre profil est maintenant à vous !"
  end

  def you_dont_have_control_of_your_account(structure, email)
    @structure = structure
    mail to: email,
         subject: "Prise de contrôle refusée"
  end

  # When user destroy his Structure
  def structure_has_been_destroy(structure)
    return if structure.admin.nil?
    @structure = structure
    mail to: @structure.admin.email,
         subject: "Votre profil vient d'être supprimé"
  end

  ######################################################################
  # User Profiles                                                      #
  ######################################################################
  def import_batch_user_profiles_finished(structure, total_wanted, error_emails)
    @structure    = structure
    @total_wanted = total_wanted
    @error_emails = error_emails
    mail to: @structure.admin.email, subject: 'Votre import est terminé.'
  end

  def import_batch_user_profiles_finished_from_newsletter(structure, newsletter, total_wanted, error_emails)
    @structure    = structure
    @total_wanted = total_wanted
    @error_emails = error_emails
    @newsletter   = newsletter
    mail to: @structure.admin.email, subject: 'Votre import est terminé.'
  end

  ######################################################################
  # Blog                                                               #
  ######################################################################

  # When a user subscribe to newsletter blog
  def subscribed_to_blog(user_email)
    mail to: user_email, subject: "Bienvenue sur la newsletter CoursAvenuePro"
  end

  # ######################################################################
  # # Send mail to webmaster                                             #
  # ######################################################################

  # When a user subscribe to newsletter blog
  def ask_webmaster_for_planning(webmaster_email, content, structure)
    @content   = content
    @structure = structure
    mail to: webmaster_email, subject: "#{@structure.name} souhaite mettre à jour son site"
  end

  private

  def generate_reply_to(sender_type = 'admin', reply_type = 'conversation')
    sender = (sender_type == 'admin' ? @admin : @user)
    return '' if sender.nil?

    reply_token      = ReplyToken.create(reply_type: reply_type)
    reply_token.data = {
      sender_type:     sender_type,
      sender_id:       sender.id,
      conversation_id: @conversation.id
    }
    reply_token.save

    reply_token.email_address
  end

end
