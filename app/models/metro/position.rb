class Metro::Position < ActiveRecord::Base
  belongs_to :line, foreign_key: 'metro_line_id', class_name: 'Metro::Line'
  belongs_to :stop, foreign_key: 'metro_stop_id', class_name: 'Metro::Stop'

  attr_accessible :line, :stop, :position
end
