class AddWidthAndHeightLogoToStructures < ActiveRecord::Migration
  def up
    add_column :structures, :logo_width, :decimal
    add_column :structures, :logo_height, :decimal

    bar = ProgressBar.new Structure.where{logo_file_name != nil}.count
    Structure.where{logo_file_name != nil}.find_each do |structure|
      bar.increment!
      begin
        if Rails.env.development?
          geometry = Paperclip::Geometry.from_file(structure.logo.path(:original))
        else
          geometry = Paperclip::Geometry.from_file(structure.logo.url(:original))
        end
        self.update_column :logo_width,  geometry.width
        self.update_column :logo_height, geometry.height
      rescue
      end
    end
  end

  def down
    remove_column :structures, :logo_width, :decimal
    remove_column :structures, :logo_height, :decimal
  end
end
