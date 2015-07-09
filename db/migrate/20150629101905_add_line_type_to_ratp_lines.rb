class AddLineTypeToRatpLines < ActiveRecord::Migration
  def change
    add_column :ratp_lines, :line_type, :string
  end
end
