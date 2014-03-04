class UpdatePassionFields < ActiveRecord::Migration
  def change
    add_column :passions, :info, :text
    add_column :passions, :level_ids, :string

    rename_column :passions, :frequency, :passion_frequency_ids
    rename_column :passions, :expectation_ids, :passion_expectation_ids
    rename_column :passions, :reason_ids, :passion_reason_ids

    add_column :passions, :passion_for_ids, :string
    add_column :passions, :passion_time_slot_ids, :string

    remove_column :passions, :subject_id
    remove_column :passions, :parent_subject_id

    create_table :passions_subjects, id: false do |t|
      t.references :passion, :subject
    end

    add_index :passions_subjects, [:passion_id, :subject_id]
  end
end
