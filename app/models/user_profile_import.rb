class UserProfileImport
  extend ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_user_profiles.map(&:valid?).all?
      imported_user_profiles.each(&:save!)
      true
    else
      imported_user_profiles.each_with_index do |product, index|
        product.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
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
    header      = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      user_profile            = UserProfile.where{email == row['email']} || UserProfile.new
      user_profile.attributes = row.to_hash.slice(*UserProfile.accessible_attributes)
      user_profile
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv"  then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls"  then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
