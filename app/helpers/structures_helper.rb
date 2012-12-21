module StructuresHelper
  def short_address(structure)
    "Paris #{structure.zip_code[3..5]}"
  end
  def readable_address(structure)
    "#{structure.street}, #{structure.zip_code}, Paris"
  end
end
