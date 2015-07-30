class CreateCommunities < ActiveRecord::Migration
  def change
    create_table :communities do |t|
      t.references :structure, index: true

      t.timestamps
    end
  end
end
