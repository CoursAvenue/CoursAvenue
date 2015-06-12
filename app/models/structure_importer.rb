require 'csv'

class StructureImporter
  attr_accessor :file

  def initialize(file = nil)
    @file = file
  end

  # Import the changes in the file.
  #
  # @return An array of structures
  def import!
    return if @file.nil?
    raw_structures = CSV.read(@file)
    raw_structures.from(1).map do |row|
      structure = structure_hash_from_row(row)
      create(structure)
      # case structure[:status]
      # when 'C' then create(structure)
      # when 'M' then update(structure)
      # when 'S' then destroy(structure)
      # end
    end
  end

  private

  def create(attributes)
    if already_exists?(attributes)
      # update(attributes)
      return
    end

    structure = Structure.create(
      name:                     attributes[:name],
      subject_ids:              get_subjects(attributes),
      website:                  attributes[:website],
      phone_numbers_attributes: get_phones(attributes),
      places_attributes:        get_places(attributes),
      contact_email:            attributes[:emails].first,
      is_sleeping:              true,
      sleeping_email_opt_in:    true,
      other_emails:             (attributes[:emails][1..-1] || []).join(';'),
      description:              attributes[:description]
    )
  end

  def update(attributes)
    if ! already_exists?(attributes)
      return
    end

    structure = get_structure(attributes)
    structure.update(
      name:                     structure[:name],
      subject_ids:              get_subjects(structure),
      website:                  structure[:website],
      phone_numbers_attributes: get_phones(structure),
      places_attributes:        get_places(structure),
      contact_email:            structure[:emails].first,
      other_emails:             (structure[:emails][1..-1] || []).join(';')
    )
  end

  def destroy(attributes)
    if ! already_exists?(attributes)
      return
    end
    structure = get_structure(attributes)
  end

  def structure_hash_from_row(structure)
    attributes = {
      status:         structure[0],
      subjects:       [structure[1],
                       structure[21],
                       structure[6],
                       structure[25],
                       structure[29],
                       structure[33],
                       structure[37]],
      parisian:       structure[2],
      vip:            structure[3],
      kids:           structure[4],
      active:         structure[5],
      name:           structure[7],
      description:    structure[8],
      profile_url:    structure[9],
      website:        structure[10],
      phones:         [structure[11], structure[13], structure[15]].compact,
      emails:         structure[17],
      streets:        [structure[19], structure[23], structure[27], structure[35]].compact,
      zip_codes:      [structure[20], structure[24], structure[28], structure[36]].compact,
      name_places:    [structure[18], structure[22], structure[26], structure[34]].compact
    }

    pattern = /\||;/ # Splitting on `|` and `;`
    attributes[:subjects] = attributes[:subjects].flatten.compact.flat_map do |subjects|
      subjects.split(pattern)
    end.uniq

    attributes[:emails] = attributes[:emails].present? ? attributes[:emails].split(pattern).compact : []

    attributes
  end

  def already_exists?(structure)
    structure[:emails].each do |email|
      if Admin.where(email: email).any? or Structure.where(contact_email: email).any?
        return true
      end
    end

    false
  end

  def get_structure(attributes)
    structure = attributes[:emails].detect do |email|
      admin = Admin.where(email: email).first
      return admin.structure if admin.present? and admin.structure.present?

      structure = Structure.where(contact_email: email).first
      return structure if structure.present?

      return false
    end
  end

  def get_places(structure)
    places_attributes = []
    structure[:zip_codes].each_with_index do |zip_code, index|
      city = City.where(City.arel_table[:zip_code].matches("%#{zip_code}%")).first
      next if city.nil?

      places_attributes << {
        name:     city.name,
        street:   structure[:streets][index],
        zip_code: zip_code,
        city_id:  city.id
      }
    end

    places_attributes
  end

  def get_phones(structure)
    phone_attributes = []
    structure[:phones].each_with_index do |phone, index|
      phone = "0#{phone}" unless phone.starts_with?('0')
      phone_attributes << { number: phone }
    end

    phone_attributes
  end

  def get_subjects(structure)
    subject_ids = []
    structure[:subjects].each_with_index do |subject_name, index|
      subject = Subject.where(Subject.arel_table[:name].matches(subject_name)).first
      next if subject.nil?

      subject_ids << subject.id
      subject_ids << subject.root.id
    end

    subject_ids.uniq
  end
end
