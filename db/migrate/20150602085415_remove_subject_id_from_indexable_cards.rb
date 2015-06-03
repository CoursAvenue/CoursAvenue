class RemoveSubjectIdFromIndexableCards < ActiveRecord::Migration
  def change
    remove_column :indexable_cards, :subject_id
  end
end
