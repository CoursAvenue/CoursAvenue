Griddler.configure do |config|
  config.processor_class = EmailProcessor # CommentViaEmail
  config.processor_method = :process # :create_comment (A method on CommentViaEmail)
  config.reply_delimiter = '-- REPONDEZ AU DESSUS DE CETTE LIGNE --'
  config.email_service = :mandrill # :cloudmailin, :postmark, :mandrill, :mailgun
end
