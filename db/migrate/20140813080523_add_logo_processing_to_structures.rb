class AddLogoProcessingToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :logo_processing, :boolean
  end
end
