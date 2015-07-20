class Ratp::Position < ActiveRecord::Base
  belongs_to :line, foreign_key: 'ratp_line_id', class_name: 'Ratp::Line'
  belongs_to :stop, foreign_key: 'ratp_stop_id', class_name: 'Ratp::Stop'

  attr_accessible :line, :stop, :position
end
