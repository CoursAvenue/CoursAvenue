class CreateNewsletterMetrics < ActiveRecord::Migration
  def change
    create_table :newsletter_metrics do |t|
      t.integer :nb_email_sent
      t.integer :nb_opening
      t.integer :nb_click
      t.references :newsletter, index: true

      t.timestamps
    end
  end
end
