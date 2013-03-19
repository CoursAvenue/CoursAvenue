class ::Admin < ActiveRecord::Base
  CIVILITY = [
    'civility.male',
    'civility.female'
  ]

  after_save :create_teacher_to_structure_if_is_teacher
  after_initialize :set_activated

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email,
                  :password,
                  :password_confirmation,
                  :remember_me,
                  :civility,
                  :first_name,
                  :last_name,
                  :phone_number,
                  :mobile_phone_number,
                  :activated,
                  :management_software_used,
                  :role,
                  :is_teacher

  validates :first_name, :last_name, :civility, presence: true, on: :update
  validates :phone_number, :presence => true, :if => "self.mobile_phone_number.blank?", on: :update

  # attr_accessible :title, :body
  belongs_to :structure

  def full_name
    "#{first_name} #{last_name}"
  end

  def active_for_authentication?
    true
  end

  private
  def set_activated
    self.activated = false
  end

  def create_teacher_to_structure_if_is_teacher
    admin_full_name = self.full_name
    if self.is_teacher
      if !self.structure.new_record? and self.structure.teachers.where{name == admin_full_name}.empty?
        self.structure.teachers.create name: admin_full_name
      end
    end
  end
end
