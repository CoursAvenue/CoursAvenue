class AddPresentationTextToWebsiteParameters < ActiveRecord::Migration
  def change
    add_column :website_parameters, :presentation_text, :text
  end
end
