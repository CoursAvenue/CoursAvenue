class AddStructureToSubscriptions < ActiveRecord::Migration
  def change
    add_reference :subscriptions, :structure, index: true
  end
end
