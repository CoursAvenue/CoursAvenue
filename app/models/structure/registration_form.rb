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

  attribute :course_type, String
  validates :course_type, presence: true

  # "Save" the managed account form.
  # We don't really save the object, but persist the attributes of the object in the related Models,
  # here the Structure and Admin models.
  #
  # @return Boolean, whether the object has been "saved".
  def save
    remove_invalid_subjects!
    valid? ? persist! : false
  end

  private

  # Create the Structure and the Admin.
  # TODO: set errors.
  #
  # @return Boolean, whether the Structure and The admin have been created or not.
  def persist!
    @structure = Structure.new(name: @structure_name)
    @structure.subjects = Subject.find(@structure_subjects_ids + @structure_subject_descendants_ids)
    @structure.save

    if !@structure.persisted?
      errors[:structure] = @structure.errors.messages
      return false
    end

    @admin = @structure.admins.create(
      email: @admin_email,
      password: @admin_password
    )

    if !@admin.persisted?
      errors[:admin] = @admin.errors.messages
      return false
    end

    # @admin.send_confirmation_instructions
    @structure.delay.index

    true
  end

  def remove_invalid_subjects!
    should_reject = lambda do |subject|
      Subject.where(id: subject.to_i).any?
    end

    @structure_subjects_ids.select!(&should_reject)
    @structure_subject_descendants_ids.select!(&should_reject)
  end
end
