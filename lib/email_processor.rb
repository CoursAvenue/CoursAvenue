class EmailProcessor
  def initialize(email)
    @email = email
  end

  # Process the received email.
  # We start by finding who sent the email.
  def process
    user      = User.where(email: @email.from[:email]).first
    structure = Structure.first # Find the structure by parsing the headers.

    UserMailer.delay.welcome(user) unless user.nil?
  end

  private
end
