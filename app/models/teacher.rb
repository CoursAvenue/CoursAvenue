class Teacher < ActiveRecord::Base
  belongs_to :structure

  attr_accessible :name, :structure_id
end
