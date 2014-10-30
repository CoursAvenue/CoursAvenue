class AddHeaderImageUrlToEmailings < ActiveRecord::Migration
  def change
    add_column :emailings, :header_url, :string
  end
end
