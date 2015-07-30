class AddCallToActionToGuides < ActiveRecord::Migration
  def change
    add_column :guides, :call_to_action, :string
  end
end
