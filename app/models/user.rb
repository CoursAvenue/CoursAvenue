class User < ActiveRecord::Base


  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :oauth_token, :oauth_expires_at,
                  :first_name, :last_name, :image, :location

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider           = auth.provider
      user.uid                = auth.uid
      user.oauth_token        = auth.credentials.token
      user.oauth_expires_at   = Time.at(auth.credentials.expires_at)

      user.first_name         = auth.info.first_name
      user.last_name          = auth.info.last_name
      user.image              = auth.info.image
      user.location           = auth.info.location
      user.save!
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
