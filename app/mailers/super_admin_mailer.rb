# encoding: utf-8
class SuperAdminMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  default from: 'CoursAvenue <hello@coursavenue.com>'
  default to:   'contact@coursavenue.com'

  def subscription_plan_export_uploaded_to_s3(subscription_plan_export)
    @export_url = subscription_plan_export.url
    mail subject: "L'export des suivis premium est terminé"
  end

  def someone_tried_to_take_control_of_existing_structure(structure, email)
    @structure = structure
    @email     = email
    mail to: 'contact@coursavenue.com', subject: "#{@email} a essayé de prendre le contrôle de #{@structure.name} en vain"
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
