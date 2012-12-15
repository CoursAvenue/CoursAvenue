module StructuresHelper
  def readable_address(structure)
    "#{structure.street}, #{structure.zip_code}, Paris"
  end
end
