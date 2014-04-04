# encoding: utf-8
class AdminMailer < ActionMailer::Base
  layout 'email'

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  def mailjet
    mail to: 'nima@coursavenue.com', subject: 'lala'
  end

  def inform_admin(subject, text)
    @text = text
    mail to: 'contact@coursavenue.com', subject: subject
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
  ######################################################################
  # The End                                                            #
  ######################################################################

  ######################################################################
  # Monday email / based on email_status                               #
  ######################################################################
  # def monday_jpo(structure)
  #   @structure  = structure
  #   @show_links = true
  #   mail to: structure.main_contact.email, subject: "J-5 avant vos Portes Ouvertes : annoncez la dernière ligne droite !"
  # end

  def no_logo_yet(structure)
    @structure  = structure
    @show_links = true
    @structures = StructureSearch.similar_profile(@structure)
    mail to: structure.main_contact.email, subject: "Ajoutez un logo ou une photo à votre profil"
  end

  def incomplete_profile(structure)
    @structure  = structure
    @show_links = true
    mail to: structure.main_contact.email, subject: "Votre profil pourrait être 7 fois plus visible"
  end

  def no_recommendations(structure)
    @structure  = structure
    @show_links = true
    mail to: structure.main_contact.email, subject: 'Votre bouche à oreille sur Internet augmente votre visibilité'
  end

  def less_than_five_recommendations(structure)
    @structure  = structure
    @show_links = true
    mail to: structure.main_contact.email, subject: 'Dépassez les 5 avis et multipliez par 7 votre visibilité'
  end

  def planning_outdated(structure)
    @structure  = structure
    @show_links = true
    mail to: structure.main_contact.email, subject: 'Mettez à jour votre planning sur CoursAvenue'
  end

  def less_than_fifteen_recommendations(structure)
    @structure  = structure
    @show_links = true
    mail to: structure.main_contact.email, subject: 'Dépassez les 15 avis et apparaissez en tête de liste'
  end
  ######################################################################
  # The End                                                            #
  ######################################################################

  def ask_for_deletion(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: 'contact@coursavenue.com', subject: 'Un professeur demande une suppression de commentaire'
  end

  def welcome_email(admin)
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
