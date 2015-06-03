class CreateIndexableCardsSubjectsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :indexable_cards, :subjects do |t|
      t.index :indexable_card_id
      t.index :subject_id
    end
  end
end
