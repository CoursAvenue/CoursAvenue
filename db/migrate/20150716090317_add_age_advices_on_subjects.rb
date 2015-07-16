class AddAgeAdvicesOnSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :age_advice_younger_than_5, :text
    add_column :subjects, :age_advice_between_5_and_9, :text
    add_column :subjects, :age_advice_older_than_10, :text
  end
end
