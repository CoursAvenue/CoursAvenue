# encoding: utf-8
class StudentMailer < ActionMailer::Base
  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.book_class.subject
  #

  def ask_friend_for_feedbacks(structure, email, comment)
    @structure = structure
    @email     = email
    @comment   = comment
    if Student.where(email: email, structure_id: @structure.id).count == 0
      Student.create(email: email, structure_id: @structure.id)
    end
    mail to: email, subject: "Recommandez #{structure.name} sur CoursAvenue"
  end

  def ask_for_feedbacks(structure, email)
    @structure = structure
    @email     = email
    if Student.where(email: email, structure_id: @structure.id).count == 0
      Student.create(email: email, structure_id: @structure.id)
    end
    mail to: email, subject: "Recommandez #{structure.name} sur CoursAvenue"
  end

  def ask_for_feedbacks_stage_1(structure, email)
    @structure = structure
    @email     = email
    mail to: email, subject: "Votre opinion sur #{structure.name}"
  end

  def ask_for_feedbacks_stage_2(structure, email)
    @structure = structure
    @email     = email
    mail to: email, subject: "Recommandez #{structure.name} sur CoursAvenue"
  end

  def ask_for_feedbacks_stage_3(structure, email)
    @structure = structure
    @email     = email
    mail to: email, subject: "Recommandez #{structure.name} sur CoursAvenue"
  end
end
