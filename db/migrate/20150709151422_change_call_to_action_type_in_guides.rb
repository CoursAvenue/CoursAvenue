class ChangeCallToActionTypeInGuides < ActiveRecord::Migration
  def up
    change_column(:guides, :call_to_action, :text)
  end

  def down
    change_column(:guides, :call_to_action, :string)
  end
end
