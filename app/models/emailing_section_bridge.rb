class EmailingSectionBridge < ActiveRecord::Base
  belongs_to :structure
  belongs_to :emailing_section
end
