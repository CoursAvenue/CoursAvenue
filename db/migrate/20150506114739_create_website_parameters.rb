class CreateWebsiteParameters < ActiveRecord::Migration
  def change
    create_table :website_parameters do |t|
      t.string :slug
      t.string :title

      t.references :structure, index: true

      t.timestamps
    end
  end
end
