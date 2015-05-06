class WebsiteParameter < ActiveRecord::Base

  belongs_to :strucutre

  validates :slug, uniqueness: true

  attr_accessible :slug, :title

  #
  # Create Website Parameter for structure if does not exist yet.
  # @param structure Structure
  #
  # @return WebsiteParameter
  def self.create_for_structure(structure)
    return structure.website_parameter if structure.website_parameter.present?
    structure.create_website_parameter slug: structure.slug, title: structure.name
  end
end
