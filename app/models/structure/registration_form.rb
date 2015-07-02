class Structure::RegistrationForm
  include ActiveModel::Model
  include Virtus.model

  attr_reader :structure
  attr_reader :admin

  attribute :structure_name, String
  validates :structure_name, presence: true

  attribute :structure_subjects_ids, Array[Integer]
  validates :structure_subjects_ids, presence: true

  attribute :structure_subject_descendants_ids, Array[Integer]
  validates :structure_subject_descendants_ids, presence: true

  attribute :admin_email, String
  validates :admin_email, presence: true

  attribute :admin_password, String
  validates :admin_password, presence: true

  # "Save" the managed account form.
  # We don't really save the object, but persist the attributes of the object in the related Models,
  # here the Structure and Admin models.
  #
  # @return Boolean, whether the object has been "saved".
  def save
    valid? ? persist! : false
  end

  private

  # Create the Structure and the Admin.
  #
  # @return Boolean, whether the Structure and The admin have been created or not.
  def persist!
    @structure = Structure.create(
      name: @structure_name,
      subject_ids: @structure_subjects_ids + @structure_subject_descendants_ids,
    )
    return false if !@structure.persisted?

    @admin = @structure.admins.create(
      email: @admin_email,
      password: @admin_password
    )
    return false if !@admin.persisted?

    true
  end

end
