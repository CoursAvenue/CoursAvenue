class AddSubjectIdToEmailingSectionBridge < ActiveRecord::Migration
  def change
    add_column :emailing_section_bridges, :subject_id, :integer
    add_column :emailing_section_bridges, :subject_name, :string
  end
end
