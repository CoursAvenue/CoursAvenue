class Newsletter::MailingList < ActiveRecord::Base
  include Concerns::HstoreHelper

  attr_accessible :name, :filters, :all_profiles

  has_many :newsletters, foreign_key: :newsletter_mailing_list_id
  belongs_to :structure

  has_many :user_profiles

  validates :name, presence: true

  store_accessor :metadata, :filters, :all_profiles
  define_array_accessor_for :metadata, :filters
  define_boolean_accessor_for :metadata, :all_profiles

  before_validation :set_name, on: :create

  # Create the recipients to send the Newsletter to.
  #
  # @return an Array of Newsletter::Recipient.
  def create_recipients
    if self.all_profiles?
      profiles = structure.user_profiles.where(subscribed: true)
    else
      profiles = filter_profiles
    end

    profiles.uniq.each do |profile|
      newsletter.recipients.create(user_profile: profile)
    end
  end

  private

  # If the name is not defined, set a default on using the define filters.
  def set_name
    if self.name.nil? or self.name.empty?
      if self.all_profiles.present? and self.all_profiles
        self.name = 'Tous les contacts du répertoire'
      else
        self.name = "Liste de diffusion du #{I18n.l(Time.current, format: :long_human)}"
      end
      save
    end
  end

  # Filter the UserProfiles using the defined filters.
  # We loop on the filters and depending on the predicate, we get the corresponding profiles.
  #
  # @return an Array of UserProfiles.
  def filter_profiles
    profiles = []
    self.filters.each do |filter|
      case
      when filter[:predicate] == 'is'
        profiles += structure.user_profiles.tagged_with(filter[:tag])

      when filter[:predicate] == 'isnot'
        profiles += structure.user_profiles.tagged_with(filter[:tag], exclude: true)

      when filter[:predicate] == 'contains'
        tags = structure.user_profiles.flat_map(&:tags).uniq.map(&:name).select do |t|
          t.include?(filter[:tag])
        end

        profiles += structure.user_profiles.tagged_with(tags)

      when filter[:predicate] == 'containsnot'
        tags = structure.user_profiles.flat_map(&:tags).uniq.map(&:name).reject do |t|
          t.include?(filter[:tag])
        end

        profiles += structure.user_profiles.tagged_with(tags)

      else
        profiles += structure.user_profiles.tagged_with(filter[:tag])
      end
    end

    profiles.select! do |profile|
      profile.subscribed?
    end

    profiles
  end
end
