class AffectingImagesToLogo < ActiveRecord::Migration
  def up
    Structure.all.each do |structure|
      if structure.image?
        structure.logo = structure.image
        structure.save
      end
    end
  end

  def down
  end
end
