class Blog::Subscriber::ProSubscriber < Blog::Subscriber

  after_create :send_email

  private

  def send_email
    AdminMailer.delay.subscribed_to_blog(self.email)
  end
end
