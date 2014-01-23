class ::Teacher < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :structure
  has_many   :plannings
  has_many   :courses, through: :plannings
  attr_accessible :name, :description, :image, :structure_id

  validates :name, presence: true

  default_scope -> { order('name ASC') }

  has_attached_file :image,
                    styles: { normal: '150x' }

  private
end
