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
end
