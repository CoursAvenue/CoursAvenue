# encoding: utf-8
class AdminMailer < ActionMailer::Base
  layout 'email'

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  ######################################################################
  # JPO                                                                #
  ######################################################################
  def invite_students_entourage(email, text, structure)
    @email_text = text
    @structure  = structure
    mail to: email, subject: 'Invitez tous vos proches à découvrir vos passions'
  end

  def inform_admin(subject, text)
    @text = text
    mail to: 'contact@coursavenue.com', subject: subject
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
    mail to: @structure.main_contact.email, subject: "Vos d’autocollants viennent d'être expédiés"
  end

  ######################################################################
  # Recommandations                                                    #
  ######################################################################
  # Inform teacher that a students has commented his establishment
  def congratulate_for_accepted_comment(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: @comment.commentable.contact_email, subject: 'Un élève vient de poster une recommandation sur votre profil'
  end

  def congratulate_for_comment(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: @comment.commentable.contact_email, subject: 'Un élève vient de poster une recommandation sur votre profil'
  end

  def congratulate_for_fifth_comment(comment)
    @comment    = comment
    @structure  = @comment.structure
    @show_links = true
    mail to: @structure.main_contact.email, subject: "Votre profil comporte déjà 5 recommandations d'élèves"
  end

  def congratulate_for_fifteenth_comment(comment)
    @comment    = comment
    @structure  = @comment.structure
    @show_links = true
    mail to: @structure.main_contact.email, subject: "Votre profil comporte déjà 15 recommandations d'élèves"
  end

  def recommandation_has_been_recovered(structure, deletion_reason)
    @structure          = structure
    deletion_reason_key = deletion_reason.split('.').last
    @email_text         = I18n.t("comments.recover_email_texts.#{deletion_reason_key}")
    @show_links         = true
    mail to: @structure.main_contact.email, subject: "Votre demande de modification d'avis a bien été prise en compte"
  end

  def recommandation_has_been_deleted(structure)
    @structure  = structure
    @show_links = true
    mail to: @structure.main_contact.email, subject: "Votre suppression d'avis a bien été prise en compte"
  end

  def remind_for_pending_comments(structure)
    @structure  = structure
    @show_links = true
    mail to: @structure.main_contact.email, subject: "Vous avez #{@structure.comments.pending.count} avis en attente de validation"
  end

  def remind_for_widget(structure)
    @structure  = structure
    @show_links = true
    mail to: @structure.main_contact.email, subject: "Vous avez accès à votre livre d'or"
  end

  # ---------------------------------------------
  # ----------------------------------------- End
  # ---------------------------------------------

  # ---------------------------------------------
  # Monday email / based on email_status
  # ---------------------------------------------

  def incomplete_profile(structure)
    @structure  = structure
    @show_links = true
    @structures = StructureSearch.similar_profile(@structure)
    mail to: structure.main_contact.email, subject: "Votre profil CoursAvenue n'est pas complet"
  end

  def no_recommendations(structure)
    @structure  = structure
    @show_links = true
    @structures = StructureSearch.similar_profile(@structure)
    mail to: structure.main_contact.email, subject: 'Vos élèves ne vous ont pas encore recommandé sur CoursAvenue'
  end

  def less_than_five_recommendations(structure)
    @structure  = structure
    @show_links = true
    @structures = StructureSearch.similar_profile(@structure)
    mail to: structure.main_contact.email, subject: 'Vous avez moins de 5 recommandations sur CoursAvenue'
  end

  def planning_outdated(structure)
    @structure  = structure
    @show_links = true
    mail to: structure.main_contact.email, subject: 'Mettez à jour votre planning de cours sur CoursAvenue'
  end

  def less_than_fifteen_recommendations(structure)
    @structure  = structure
    @show_links = true
    mail to: structure.main_contact.email, subject: 'Vous avez moins de 15 recommandations sur CoursAvenue'
  end

  # ---------------------------------------------
  # Monday email / based on email_status
  # ---------------------------------------------

  def ask_for_deletion(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: 'contact@coursavenue.com', subject: 'Un professeur demande une suppression de commentaire'
  end

  def admin_validated(admin)
    @admin         = admin
    @structure     = @admin.structure
    @show_links    = true
    @structures    = StructureSearch.similar_profile(@structure)
    mail to: @admin.email, subject: 'Bienvenue sur CoursAvenue'
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

end
