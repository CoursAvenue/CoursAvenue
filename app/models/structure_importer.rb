require 'csv'

class StructureImporter
  attr_accessor :file

  def initialize(file)
    @file = file
  end

  # Import the changes in the file.
  #
  # @return An array of structures
  def import!
  end
end
