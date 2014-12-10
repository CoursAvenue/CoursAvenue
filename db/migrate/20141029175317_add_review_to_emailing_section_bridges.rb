class AddReviewToEmailingSectionBridges < ActiveRecord::Migration
  def change
    add_column :emailing_section_bridges, :review_id, :integer
    add_column :emailing_section_bridges, :review_text, :string
    add_column :emailing_section_bridges, :review_custom, :boolean
  end
end
