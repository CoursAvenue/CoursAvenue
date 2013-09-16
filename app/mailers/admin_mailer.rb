# encoding: utf-8
class AdminMailer < ActionMailer::Base
  layout 'email'

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

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

  # Inform teacher that a students has commented his establishment
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
    mail to: email, subject: "#{structure.name} vous invite à mettre en avant la qualité de vos cours"
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
                                          })
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
                                          })
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
                                          })
    end
    @structures = @structures.flatten
    return @structures
  end
end
