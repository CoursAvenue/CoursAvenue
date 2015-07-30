Griddler.configure do |config|
  config.processor_class = EmailProcessor
  config.processor_method = :process
  config.reply_delimiter = 'REPONDEZ AU DESSUS DE CETTE LIGNE'
  config.email_service = :mandrill
end
