# encoding: utf-8
class AdminMailer < ActionMailer::Base
  layout 'email'

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"


  def inform_admin(subject, text)
    @text = text
    mail to: 'contact@coursavenue.com', subject: subject
  end
  # ---------------------------------------------
  # Stickers
  # ---------------------------------------------
  def stickers_has_been_ordered(sticker_demand)
    @structure = sticker_demand.structure
    mail to: @structure.main_contact.email, subject: 'Votre commande d’autocollants a bien été prise en compte'
  end

  def stickers_has_been_sent(sticker_demand)
    @structure = sticker_demand.structure
    mail to: @structure.main_contact.email, subject: "Vos d’autocollants viennent d'être expédiés"
  end

  # ---------------------------------------------
  # Recommandations
  # ---------------------------------------------

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

  def recommandation_has_been_recovered(structure)
    @structure  = structure
    @show_links = true
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
    @structures = similar_profile
    mail to: structure.main_contact.email, subject: "Votre profil CoursAvenue n'est pas complet"
  end

  def no_recommendations(structure)
    @structure  = structure
    @show_links = true
    @structures = similar_profile
    mail to: structure.main_contact.email, subject: 'Vos élèves ne vous ont pas encore recommandé sur CoursAvenue'
  end

  def less_than_five_recommendations(structure)
    @structure  = structure
    @show_links = true
    @structures = similar_profile
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


  def inform_invitation_success(structure, invited_email)
    @structure     = structure
    @invited_email = invited_email
    @show_links    = true
    mail to: @structure.main_contact.email, subject: "Félicitations ! Votre parrainage a bien été pris en compte"
  end

  def recommand_friends(structure, email_text, email)
    @structure  = structure
    @email_text = email_text
    @email      = email
    mail to: email, subject: "#{structure.name} vous invite à créer votre profil sur CoursAvenue."
  end

  def send_invitation_stage_1(structure, invited_email)
    @structure     = structure
    @invited_email = invited_email
    mail to: invited_email, subject: "#{structure.name} vous invite à créer votre profil sur CoursAvenue."
  end

  def send_invitation_stage_2(structure, invited_email)
    @structure     = structure
    @invited_email = invited_email
    mail to: invited_email, subject: "#{structure.name} vous invite à créer votre profil sur CoursAvenue."
  end

  def admin_validated(admin)
    @admin         = admin
    @structure     = @admin.structure
    @show_links    = true
    @structures    = similar_profile
    mail to: @admin.email, subject: 'Bienvenue sur CoursAvenue'
  end

  def new_admin_has_signed_up(admin)
    @admin     = admin
    @structure = admin.structure
    if Rails.env.development?
      mail to: 'nim.izadi@gmail.com', subject: "Un prof vient de s'enregistrer !"
    else
      mail to: 'all@coursavenue.com', subject: "Un prof vient de s'enregistrer !"
    end
  end

  private

  def similar_profile
    parent_subject = @structure.subjects.first
    parent_subject = parent_subject.parent if parent_subject and parent_subject.parent
    parent_subject = parent_subject.parent if parent_subject and parent_subject.parent
    @structures    = []
    if parent_subject
      @structures << StructureSearch.search({lat: @structure.latitude,
                                            lng: @structure.longitude,
                                            radius: 3,
                                            sort: 'rating_desc',
                                            has_logo: true,
                                            per_page: 3,
                                            subject_id: parent_subject.slug
                                          }).results
      # If there is not enough with the same subjects
    end
    @structures = @structures.flatten
    if @structures.length < 3
      @structures << StructureSearch.search({lat: @structure.latitude,
                                            lng: @structure.longitude,
                                            radius: 3,
                                            sort: 'rating_desc',
                                            has_logo: true,
                                            per_page: (3 - @structures.length)
                                          }).results
    end
    @structures = @structures.flatten
    # If there is not enough within the radius
    if @structures.length < 3
      @structures << StructureSearch.search({lat: @structure.latitude,
                                            lng: @structure.longitude,
                                            radius: 7,
                                            sort: 'rating_desc',
                                            has_logo: true,
                                            per_page: (3 - @structures.length)
                                          }).results
    end
    @structures = @structures.flatten
    return @structures
  end
end
