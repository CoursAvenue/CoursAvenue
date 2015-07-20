class AddRouteNameToMetroLines < ActiveRecord::Migration
  def change
    add_column :metro_lines, :route_name, :string
  end
end
