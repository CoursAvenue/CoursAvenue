# encoding: utf-8
class AdminMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'
  helper :structures

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

  def subscription_renewal_failed(structure, params)
    @structure = structure
    @params    = params
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

  def wants_to_go_premium structure, offer
    @structure = structure
    @offer     = offer
    mail to: 'contact@coursavenue.com', subject: 'Un professeur veut passer premium'
  end

  def go_premium structure, offer
    @structure = structure
    @offer     = offer
    mail to: 'contact@coursavenue.com', subject: 'Un professeur est passé premium'
  end

  def go_premium_fail structure, params
    @structure = structure
    @params    = params
    mail to: 'nima@coursavenue.com', subject: 'Un professeur voulait passer premium mais a échoué'
  end

  def be2bill_transaction_notifications structure, params
    @structure = structure
    @params    = params
    mail to: 'nima@coursavenue.com', subject: 'Be2Bill transaction notifiaction'
  end

  def inform_admin(subject, text)
    @text = text
    mail to: 'contact@coursavenue.com', subject: subject
  end

  def user_is_now_following_you(structure, user)
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
         subject: "Rappel : demande d'information - #{@user.name}"
  end

  def message_information_reminder_2(conversation, admin)
    @conversation = conversation
    @message      = conversation.messages.first
    @admin        = admin
    @structure    = admin.structure
    @user         = conversation.recipients.select{|recipient| recipient.is_a? User }.first
    mail to: @admin.email,
         subject: "Rappel : demande d'information - #{@user.name}"
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

  def congratulate_for_fifth_comment(comment)
    @comment    = comment
    @structure  = @comment.structure
    mail to: @structure.main_contact.email,
         subject: "Bravo ! Vous avez accès à votre livre d'or"
  end

  def congratulate_for_fifteenth_comment(comment)
    @comment    = comment
    @structure  = @comment.structure
    mail to: @structure.main_contact.email,
         subject: "Bravo ! Votre profil comporte déjà 15 avis",
         from: 'CoursAvenue <hello@coursavenue.com>'
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

  def your_profile_has_been_viewed(structure)
    return if structure.premium?
    @structure         = structure
    @view_count        = @structure.view_count(30)
    @impressions_count = @structure.impression_count(30)
    @similar_profiles  = @structure.similar_profiles(2)
    mail to: structure.main_contact.email, subject: "Votre profil a été vu #{@view_count} fois"
  end

  def incomplete_profile(structure)
    @structure  = structure
    mail to: structure.main_contact.email,
         subject: 'Votre profil 7 fois plus visible'
  end

  def planning_outdated(structure)
    @structure        = structure
    @similar_profiles = @structure.similar_profiles(2)
    mail to: structure.main_contact.email,
         subject: "Votre profil n'affiche pas de cours"
  end
  ######################################################################
  # The End                                                            #
  ######################################################################

  def no_more_active_courses(structure)
    @structure        = structure
    @similar_profiles = @structure.similar_profiles(2)
    mail to: structure.main_contact.email,
         subject: "Votre profil n'affiche plus de cours"
  end

  def new_admin_has_signed_up(admin)
    @admin     = admin
    @structure = admin.structure
    if Rails.env.development?
      mail to: 'nim.izadi@gmail.com', subject: "Un prof vient de s'enregistrer !"
    else
      mail to: 'inscription@coursavenue.com', subject: "Un prof vient de s'enregistrer !"
    end
  end

  def take_control_of_your_account(structure)
    return if structure.contact_email.blank?
    return if !structure.sleeping_email_opt_in
    return if structure.main_contact.present?
    @structure = structure
    mail to: structure.contact_email, subject: "Prenez le contrôle de votre profil"
    if @structure.other_emails.present?
      @structure.other_emails.split(';').each do |email|
        mail to: email, subject: "Prenez le contrôle de votre profil"
      end
    end
  end

  def you_have_control_of_your_account(structure)
    @structure        = structure
    mail to: structure.main_contact.email,
         subject: "Votre profil est maintenant à vous !"
  end

  ######################################################################
  # To CoursAvenue team                                                #
  ######################################################################
  def is_about_to_delete(structure)
    @structure = structure
    mail to: 'contact@coursavenue.com', subject: "#{@structure.name} est sur le point de supprimer son compte"
  end

  def has_destroyed(structure)
    @structure = structure
    mail to: 'contact@coursavenue.com', subject: "#{@structure.name} a supprimé son compte..."
  end

  def ask_for_deletion(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: 'contact@coursavenue.com', subject: 'Un professeur demande une suppression de commentaire'
  end
end
