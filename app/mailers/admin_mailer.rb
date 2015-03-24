# encoding: utf-8
class AdminMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'
  helper :application, :structures

  default from: 'CoursAvenue <hello@coursavenue.com>'

  ######################################################################
  # For premium users                                                  #
  ######################################################################
  def commercial_email_2
    mail to: "adz@azd.az", subject: 'Votre profil Premium est activé'
  end

  def commercial_email(structure)
    return
    @structure = structure
    # mail to: @structure.main_contact.email,
    #      subject: "★ Dernier jour à -50%",
    #      from: "L'équipe CoursAvenue <contact@coursavenue.com>"
  end

  def subscription_renewal_failed(structure)
    @structure = structure
    mail to: @structure.main_contact.email,
         subject: 'Il y a un problème avec votre abonnement CoursAvenue',
         from: 'CoursAvenue Premium <premium@coursavenue.com>'
  end

  def your_premium_account_has_been_activated(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    mail to: @structure.main_contact.email,
         subject: 'Votre profil Premium est activé',
         from: 'CoursAvenue Premium <premium@coursavenue.com>'
  end

  def fifteen_days_to_end_of_subscription(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    @similar_profiles  = @structure.similar_profiles(2)
    mail to: @structure.main_contact.email,
         subject: 'Votre profil Premium renouvelé dans 15 jours',
         from: 'CoursAvenue Premium <premium@coursavenue.com>'
  end

  def five_days_to_end_of_subscription(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    @similar_profiles  = @structure.similar_profiles(2)
    mail to: @structure.main_contact.email,
         subject: 'Votre profil Premium sera renouvelé dans 5 jours',
         from: 'CoursAvenue Premium <premium@coursavenue.com>'
  end

  def subscription_has_been_renewed(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    @similar_profiles  = @structure.similar_profiles(2)
    mail to: @structure.main_contact.email,
         subject: 'Votre profil Premium a été renouvelé',
         from: 'CoursAvenue Premium <premium@coursavenue.com>'
  end

  def subscription_has_been_canceled(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    mail to: @structure.main_contact.email,
         subject: 'Résiliation de votre profil Premium'
  end

  def subscription_has_been_reactivated(subscription_plan)
    @structure         = subscription_plan.structure
    @subscription_plan = subscription_plan
    mail to: @structure.main_contact.email,
         subject: 'Votre réabonnement au Premium a bien été pris en compte'
  end

  def premium_follow_up_with_promo_code structure, monthyl_promo_code, annual_promo_code
    return if annual_promo_code.nil? or monthyl_promo_code.nil?
    @structure          = structure
    @monthly_promo_code = monthyl_promo_code
    @annual_promo_code  = annual_promo_code
    mail to: @structure.main_contact.email, subject: "Que s'est-il passé ?"
  end

  def user_is_now_following_you(structure, user)
    return if structure.main_contact.nil?
    @structure        = structure
    @user             = user
    @similar_profiles = @structure.similar_profiles(2)
    mail to: @structure.main_contact.email, subject: "Votre profil vient d'être ajouté en favori"
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
  # JPOs                                                               #
  ######################################################################
  def your_jpo_courses_are_visible(structure)
    @structure = structure
    mail to: @structure.main_contact.email, subject: 'Vos ateliers pour les Portes Ouvertes sont maintenant visibles'
  end

  ######################################################################
  # Stickers                                                           #
  ######################################################################
  def stickers_has_been_ordered(sticker_demand)
    @structure = sticker_demand.structure
    mail to: @structure.main_contact.email, subject: 'Votre commande d’autocollants a bien été prise en compte'
  end

  def stickers_has_been_sent(sticker_demand)
    @structure = sticker_demand.structure
    mail to: @structure.main_contact.email, subject: "Vos autocollants viennent d'être expédiés"
  end

  ######################################################################
  # Recommandations                                                    #
  ######################################################################
  # Inform teacher that a students has commented his establishment
  def congratulate_for_accepted_comment(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: @comment.commentable.contact_email, subject: "Vous avez reçu un avis de #{@comment.author_name}"
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
    mail to: @structure.main_contact.email, subject: "Votre demande de modification d'avis a bien été prise en compte"
  end

  def recommandation_has_been_deleted(structure)
    @structure  = structure
    mail to: @structure.main_contact.email, subject: "Votre suppression d'avis a bien été prise en compte"
  end

  def remind_for_pending_comments(structure)
    @structure  = structure
    return if @structure.main_contact.nil?
    mail to: @structure.main_contact.email,
         subject: "Vous avez #{@structure.comments.pending.count} avis en attente de validation"
  end

  def remind_for_widget(structure)
    @structure  = structure
    mail to: @structure.main_contact.email, subject: "Vous avez accès à votre livre d'or"
  end
  ######################################################################
  # The End                                                            #
  ######################################################################

  ######################################################################
  # Monday email / based on email_status                               #
  ######################################################################
  # def monday_jpo(structure)
  #   @structure  = structure
  #   mail to: structure.main_contact.email, subject: "J-5 avant vos Portes Ouvertes : annoncez la dernière ligne droite !"
  # end

  def incomplete_profile(structure)
    return if structure.is_sleeping?
    @structure  = structure
    mail to: structure.main_contact.email,
         subject: 'Votre profil 7 fois plus visible'
  end

  def planning_outdated(structure)
    return if structure.is_sleeping?
    @structure        = structure
    @similar_profiles = @structure.similar_profiles(2, { has_admin: true })
    mail to: structure.main_contact.email,
         subject: "Votre profil n'affiche pas de cours"
  end
  ######################################################################
  # The End                                                            #
  ######################################################################

  def no_more_active_courses(structure)
    @structure        = structure
    @similar_profiles = @structure.similar_profiles(2, { has_admin: true })
    mail to: structure.main_contact.email,
         subject: "Votre profil n'affiche plus de cours"
  end

  def take_control_of_your_account(structure, email=nil)
    return if !structure.should_send_email?
    return if structure.contact_email.blank?
    return if !structure.sleeping_email_opt_in
    return if structure.main_contact.present?
    @structure = structure
    mail to: (email || structure.contact_email),
         subject: "★ Recrutez gratuitement de nouveaux élèves sur Internet",
         from: 'CoursAvenue <info@coursavenue.com>'
  end

  def you_have_control_of_your_account(structure)
    @structure        = structure
    mail to: structure.main_contact.email,
         subject: "Votre profil est maintenant à vous !"
  end

  def you_dont_have_control_of_your_account(structure, email)
    @structure = structure
    mail to: email,
         subject: "Prise de contrôle refusée"
  end

  # When user destroy his Structure
  def structure_has_been_destroy(structure)
    return if structure.main_contact.nil?
    @structure = structure
    mail to: @structure.main_contact.email,
         subject: "Votre profil vient d'être supprimé"
  end

  ######################################################################
  # User Profiles                                                      #
  ######################################################################
  def import_batch_user_profiles_finished(structure, total_wanted, error_emails)
    @structure    = structure
    @total_wanted = total_wanted
    @error_emails = error_emails
    mail to: @structure.main_contact.email, subject: 'Votre import est terminé.'
  end
  ######################################################################
  # Blog                                                               #
  ######################################################################

  # When a user subscribe to newsletter blog
  def subscribed_to_blog(user_email)
    mail to: user_email, subject: "Bienvenue sur la newsletter CoursAvenuePro"
  end

  private

  def generate_reply_to(sender_type = 'admin')
    reply_token      = ReplyToken.create(reply_type: 'conversation')
    reply_token.data = {
      sender_type:     sender_type,
      sender_id:       sender_type == 'admin' ? @admin.id : @user.id,
      conversation_id: @conversation.id
    }
    reply_token.save

    return "CoursAvenue <#{reply_token.token}@#{CoursAvenue::Application::MANDRILL_REPLY_TO_DOMAIN}"
  end

end
