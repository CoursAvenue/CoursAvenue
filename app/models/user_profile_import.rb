class UserProfileImport < ActiveRecord::Base
  extend ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessible :structure_id, :data, :filename, :mime_type

  validates :structure_id, :data, :filename, :mime_type, presence: true

  attr_accessor :file, :file_id, :structure_id,
                                 :email_index,
                                 :first_name_index,
                                 :last_name_index,
                                 :birthdate_index,
                                 :notes_index,
                                 :phone_index,
                                 :mobile_phone_index,
                                 :address_index

  belongs_to :structure

  def import
    if imported_user_profiles.map(&:valid?).all?
      imported_user_profiles.each(&:save!)
      true
    else
      imported_user_profiles.each_with_index do |user_profile, index|
        user_profile.errors.full_messages.each do |message|
          errors.add :base, "Ligne #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_user_profiles
    @imported_user_profiles ||= load_imported_user_profiles
  end

  def headers
    spreadsheet = open_spreadsheet
    header      = spreadsheet.row(1)
  end

  def load_imported_user_profiles
    spreadsheet = open_spreadsheet
    # header      = spreadsheet.row(1)

    (2..spreadsheet.last_row).map do |i|
      row = {}
      user_profile_accessible_attributes.map do |attribute_name|
        if (index = self.send("#{attribute_name}_index")).present?
          row[attribute_name] = spreadsheet.row(i)[index.to_i]
        else
          row[attribute_name] = nil
        end
      end
      # row = Hash[[header, spreadsheet.row(i)].transpose]
      # Prevents from blank email affecting some bs
      if row['email'].present?
        row['email'] = strip_noise(row['email'])
        _structure_id = self.structure_id
        user_profile = UserProfile.where{(structure_id == _structure_id) && (email == row['email'])}.first || UserProfile.new
      else
        user_profile = UserProfile.new
      end
      user_profile.attributes = row.slice(*UserProfile.accessible_attributes)
      user_profile.structure_id = self.structure_id
      user_profile
    end
  end

  def file
    if @file.nil?
      unless @tempfile
        @tempfile = Tempfile.new(self.filename)
        @tempfile.write(self.data.force_encoding('UTF-8'))
      end
      @tempfile
    else
      @file
    end
  end

  def user_profile_accessible_attributes
    ['email', 'first_name', 'last_name', 'birthdate', 'notes', 'phone', 'mobile_phone', 'address']
  end

  def open_spreadsheet
    case File.extname(self.filename)
    when ".csv"  then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls"  then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  # Remove non breaking spaces
  def strip_noise(string)
    ActiveSupport::Inflector.transliterate string.to_s, ''
  end
end
