class Subject < ActiveRecord::Base
  include IdentityCache
  include Concerns::IdentityCacheFetchHelper
  include AlgoliaSearch

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  acts_as_tree cache_depth: true, touch: true

  ######################################################################
  # Relations                                                          #
  ######################################################################
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :structures
  has_and_belongs_to_many :users
  has_and_belongs_to_many :comments
  has_and_belongs_to_many :medias
  has_and_belongs_to_many :indexable_cards

  has_many :vertical_pages
  has_many :passions
  has_many :city_subject_infos

  ######################################################################
  # Caching                                                            #
  ######################################################################

  cache_has_many :structures, inverse_name: :subjects
  cache_index :slug, unique: true

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :name, presence: true
  validates :name, uniqueness: { scope: 'ancestry' }

  ######################################################################
  # Scopes                                                            #
  ######################################################################
  scope :children,               -> { where(Subject.arel_table[:ancestry].not_eq(nil)) }
  scope :little_children,        -> { where(Subject.arel_table[:ancestry_depth].eq(2)) }
  scope :roots_with_position,    -> { where(Subject.arel_table[:ancestry].eq(nil).and(Subject.arel_table[:position].not_eq(nil))) }
  scope :roots_without_position, -> { where(Subject.arel_table[:ancestry].eq(nil).and(Subject.arel_table[:position].not_eq(nil))) }
  scope :stars,                  -> { where(Subject.arel_table[:position].lt(10)).order('position ASC') }
  scope :roots_not_stars,        -> { where(Subject.arel_table[:position].gt(10).and(Subject.arel_table[:ancestry].eq(nil))).order('position ASC') }

  attr_accessible :name, :short_name, :info, :parent, :position, :title, :subtitle, :description, :image,
                  :good_to_know, :needed_meterial, :tips, :ancestry

  has_attached_file :image,
                    :styles => { super_wide: "825x250#", wide: "600x375#", small: '250x200#', thumb: "200x200#" },
                    processors: [:thumbnail, :paperclip_optimizer]

  validates_attachment_content_type :image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  # :nocov:
  searchable do
    text :name
  end
  # :nocov:

  # :nocov:
  algoliasearch per_environment: true, disable_indexing: Rails.env.test? do
    attribute :slug, :depth
    add_attribute :name do
      self.name.gsub(' de ', ' ').gsub("d'", '')
    end
    add_attribute :root_name do
      self.root.name
    end
    add_attribute :type do
      'subject'
    end
    add_attribute :parent_name do
      self.parent.name.gsub(' de ', ' ').gsub("d'", '') unless self.depth == 0
    end
    add_attribute :parent do
      self.parent.slug unless self.depth == 0
    end
    add_attribute :root do
      self.root.slug
    end
  end
  # :nocov:

  # Tells wether the given subject is a descendant of self by checking its ancestry string
  # @param  subject [type] [description]
  #
  # @return Boolean
  def descendant_of?(supposed_root)
    return false if self.ancestry.blank? or supposed_root.nil?
    _ancestor_ids = self.ancestor_ids
    if supposed_root.is_a? Array
      return supposed_root.find{|_supposed_root| _ancestor_ids.include?(_supposed_root.id) } || false
    else
      return _ancestor_ids.include? supposed_root.id
    end
  end

  def little_children
    self.descendants.at_depth(2)
  end

  def grand_parent
    if parent and parent.parent
      parent.parent
    elsif parent
      parent
    else
      nil
    end
  end

  def as_json(options = {})
    {
      id:          self.id,
      name:        self.name,
      parent_name: self.parent.try(:name),
      slug:        self.slug
    }
  end

  def good_to_know
    if read_attribute(:good_to_know).nil? and self.parent
      self.parent.good_to_know
    else
      read_attribute(:good_to_know)
    end
  end

  def needed_meterial
    if read_attribute(:needed_meterial).nil? and self.parent
      self.parent.needed_meterial
    else
      read_attribute(:needed_meterial)
    end
  end

  def tips
    if read_attribute(:tips).nil? and self.parent
      self.parent.tips
    else
      read_attribute(:tips)
    end
  end
end
