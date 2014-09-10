# encoding: utf-8
class SuperAdminMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  default from: 'CoursAvenue <hello@coursavenue.com>'
  default to:   'sites+coursavenue@aliou.me'

  def subscription_plan_export_uploaded_to_s3(export_url)
    @export_url = export_url
    mail subject: "L'export des suivis premium est terminé"
  end
end
