class Blog::Subscriber::UserSubscriber < Blog::Subscriber

  after_create :create_associated_user

  belongs_to :user

  attr_accessible :email, :type, :user_id

  private

  def create_associated_user
    self.user = User.where(email: self.email).first_or_create
    user.save(validate: false)
    self.save
    UserMailer.delay(queue: 'mailers').subscribed_to_blog(user)
  end
end
