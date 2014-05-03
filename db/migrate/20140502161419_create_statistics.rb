class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.references :structure
      t.string     :action_type
      t.timestamps
    end
  end
end
