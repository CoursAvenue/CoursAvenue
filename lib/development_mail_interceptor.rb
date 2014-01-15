class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    if Rails.env.staging?
      message.to = "nim.izadi@gmail.com, lagardenicolas@gmail.com"
    else
      message.to = "nim.izadi@gmail.com"
    end
  end
end
