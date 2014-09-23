class RenameSectionUrlToLink < ActiveRecord::Migration
  def change
    rename_column :emailing_sections, :url, :link
  end
end
