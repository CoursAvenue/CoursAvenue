class NewsletterUser < ActiveRecord::Base
  attr_accessible :email, :city, :structure_id

  belongs_to :structure

  validates :email, uniqueness: {scope: 'structure_id'}

  validates :email, presence: true
  validates :email, format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }

  after_save :subscribe_to_mailchimp if Rails.env.production?

  private
  def subscribe_to_mailchimp
    Gibbon.list_subscribe({:id => CoursAvenue::Application::MAILCHIMP_USERS_LIST_ID,
                           :email_address => self.email,
                           :merge_vars => {
                              :NAME => self.structure.name,
                              :STATUS => 'not registered'
                           },
                           :double_optin => false,
                           :update_existing => true,
                           :send_welcome => false})
  end
end
