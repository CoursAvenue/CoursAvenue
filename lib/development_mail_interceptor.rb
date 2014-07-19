class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to = "nim.izadi@gmail.com, nima.izadi@hotmail.fr, izadi.nima@orange.fr"
    # message.to = "nim.izadi@gmail.com"
  end
end
