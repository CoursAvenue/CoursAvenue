class Teacher < ActiveRecord::Base
  belongs_to :structure

  attr_accessible :name, :description, :structure_id
end
