class AddDefaultsToNewsletterMetrics < ActiveRecord::Migration
  def up
    change_column :newsletter_metrics, :nb_email_sent, :integer, default: 0
    change_column :newsletter_metrics, :nb_opening,    :integer, default: 0
    change_column :newsletter_metrics, :nb_click,      :integer, default: 0
    change_column :newsletter_metrics, :nb_bounced,    :integer, default: 0
  end

  def down
    change_column :newsletter_metrics, :nb_bounced,    :integer, default: nil
    change_column :newsletter_metrics, :nb_click,      :integer, default: nil
    change_column :newsletter_metrics, :nb_opening,    :integer, default: nil
    change_column :newsletter_metrics, :nb_email_sent, :integer, default: nil
  end
end
