class AddNbBouncedToNewsletterMetrics < ActiveRecord::Migration
  def change
    add_column :newsletter_metrics, :nb_bounced, :integer
  end
end
