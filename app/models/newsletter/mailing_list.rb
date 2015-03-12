class Newsletter::MailingList < ActiveRecord::Base
  include Concerns::HstoreHelper

  attr_accessible :name, :filters

  belongs_to :newsletter
  belongs_to :structure

  has_many :user_profiles

  validates :name, presence: true

  store_accessor :metadata, :filters
  define_array_accessor_for :metadata, :filters

  before_create :set_name

  # Create the recipients from the defined filters and their subscription state.
  # We loop on the filters and depending on the predicate, we get the corresponding profiles and
  # transform them into recipients.
  #
  # @return an Array of Newsletter::Recipients.
  def create_recipients
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

    profiles.uniq.each do |profile|
      newsletter.recipients.create(user_profile: profile)
    end
  end

  private

  # If the name is not defined, set a default on using the define filters.
  def set_name
    if self.name.nil?
      self.name = "Liste de diffusion du #{I18n.l(Time.current, format: :long_name)}"
      save
    end
  end
end
