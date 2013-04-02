class Participant < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name

  belongs_to :reservation

end
