class ::Admin < ActiveRecord::Base
  CIVILITY = [
    'civility.male',
    'civility.female'
  ]

  after_create :create_teacher_to_structure_if_no_teacher

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email,
                  :password,
                  :password_confirmation,
                  :remember_me,
                  :civility,
                  :name,
                  :first_name,
                  :last_name,
                  :phone_number,
                  :mobile_phone_number,
                  :active,
                  :management_software_used,
                  :role,
                  :is_teacher,
                  :structure_id

  validates :name, presence: true, on: :create

  # attr_accessible :title, :body
  belongs_to :structure

  def full_name
    "#{first_name} #{last_name}"
  end

  def active_for_authentication?
    true
  end

  private

  def create_teacher_to_structure_if_no_teacher
    if structure.teachers.empty?
      self.structure.teachers.create name: self.name
    end
  end
end
