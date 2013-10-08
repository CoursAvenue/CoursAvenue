# encoding: utf-8
class StudentMailer < ActionMailer::Base
  layout 'email'

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.book_class.subject
  #

  def recommend_structure(structure_name, structure_email, recommendation)
    @structure_name  = structure_name
    @structure_email = structure_email
    @recommendation  = recommendation
    mail to: 'contact@coursavenue.com', subject: "Un élève vient de recommander un professeur"
  end

  def ask_for_feedbacks(structure, email_text, email)
    @structure  = structure
    @email      = email
    @email_text = email_text
    if Student.where(email: email, structure_id: @structure.id).count == 0
      @student = Student.create(email: email, structure_id: @structure.id)
    else
      @student = Student.where(email: email, structure_id: @structure.id).first
    end
    mail to: email, subject: "#{structure.name} vous demande une recommandation"
  end

  def ask_for_feedbacks_stage_1(structure, email)
    @structure = structure
    @email     = email
    @student   = Student.where(email: email, structure_id: @structure.id).first
    mail to: email, subject: "Votre opinion sur #{structure.name}"
  end

  def ask_for_feedbacks_stage_2(structure, email)
    @structure = structure
    @email     = email
    @student   = Student.where(email: email, structure_id: @structure.id).first
    mail to: email, subject: "#{structure.name} vous demande une recommandation"
  end

  def ask_for_feedbacks_stage_3(structure, email)
    @structure = structure
    @email     = email
    @student   = Student.where(email: email, structure_id: @structure.id).first
    mail to: email, subject: "#{structure.name} vous demande une recommandation"
  end
end
