# encoding: utf-8
class UserMailer < ActionMailer::Base
  layout 'email'

  helper :prices, :comments

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"


  ######################################################################
  # Email reminder                                                     #
  ######################################################################
  # Monday email to push the user to fill passions
  def monday_jpo(user)
    @user    = user
    mail to: @user.email, subject: 'Invitation aux Portes Ouvertes des cours de loisirs les 5 et 6 avril à Paris'
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
    mail to: 'contact@coursavenue.com', subject: 'Suite de votre message sur CoursAvenue'
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
    @structure = @comment.structure
    mail to: @comment.email, subject: "Votre avis à propos de : #{@structure.name}"
  end

  # Inform the user that the comment has correctly been submitted
  def congratulate_for_comment(comment)
    @comment   = comment
    @structure = @comment.structure
    mail to: @comment.email, subject: "Votre avis à propos de : #{@structure.name}"
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
  def ask_for_recommandations(structure, email_text, email)
    @structure  = structure
    @email      = email
    user_email  = email
    @user       = User.where{email == user_email}.first
    @email_text = email_text
    mail to: email, subject: "#{structure.name} vous demande une recommandation"
  end

  def ask_for_recommandations_stage_1(structure, email)
    @structure = structure
    @email     = email
    user_email  = email
    @user       = User.where{email == user_email}.first
    mail to: email, subject: "Votre opinion sur #{structure.name}"
  end

  def ask_for_recommandations_stage_2(structure, email)
    @structure = structure
    @email     = email
    user_email  = email
    @user       = User.where{email == user_email}.first
    mail to: email, subject: "#{structure.name} vous demande une recommandation"
  end

  def ask_for_recommandations_stage_3(structure, email)
    @structure = structure
    @email     = email
    user_email  = email
    @user       = User.where{email == user_email}.first
    mail to: email, subject: "Dernier jour pour recommander #{structure.name}"
  end
end
