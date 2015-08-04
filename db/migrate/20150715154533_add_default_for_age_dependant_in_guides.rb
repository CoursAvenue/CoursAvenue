class AddDefaultForAgeDependantInGuides < ActiveRecord::Migration
  def up
    change_column_default :guides, :age_dependant, false
    Guide.update_all(age_dependant: false)
  end

  def down
    change_column_default :guides, :age_dependant, nil
    Guide.update_all(age_dependant: nil)
  end
end
