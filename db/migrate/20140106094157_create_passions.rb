class CreatePassions < ActiveRecord::Migration
  def change
    create_table :passions do |t|
      t.references :user
      t.references :subject

      t.integer    :parent_subject_id

      t.string     :frequency
      t.boolean    :practiced, default: true
      t.string     :expectation_ids
      t.string     :reason_ids

      t.timestamps
    end
  end
end
