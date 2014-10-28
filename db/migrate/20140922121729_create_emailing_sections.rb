class CreateEmailingSections < ActiveRecord::Migration
  def change
    create_table :emailing_sections do |t|
      t.string :title
      t.belongs_to :emailing

      t.timestamps
    end
  end
end
