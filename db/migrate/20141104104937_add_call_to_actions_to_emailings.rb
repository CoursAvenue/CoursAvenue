class AddCallToActionsToEmailings < ActiveRecord::Migration
  def change
    add_column :emailings, :call_to_action_text, :string
    add_column :emailings, :call_to_action_url, :string
  end
end
