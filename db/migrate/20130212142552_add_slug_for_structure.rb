class AddSlugForStructure < ActiveRecord::Migration
  def change
    add_column :structures, :slug, :string
    add_index  :structures, :slug, unique: true
    # Regenerate slug
    Structure.all.each do |s|
      s.save
    end
  end
end
