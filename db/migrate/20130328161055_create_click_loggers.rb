class CreateClickLoggers < ActiveRecord::Migration
  def change
    create_table :click_loggers do |t|
      t.string :name

      t.timestamps
    end
  end
end
