require "omnicontacts"

Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, '519425112113.apps.googleusercontent.com', 'PhuIrMdUtyK9DboXJjHjDVM3', {:redirect_path => '/etablissements/import_mail_callback'}
  # importer :yahoo, "consumer_id", "consumer_secret", {:callback_path => '/callback'}
  # importer :hotmail, "client_id", "client_secret"
  # importer :facebook, "client_id", "client_secret"
end
