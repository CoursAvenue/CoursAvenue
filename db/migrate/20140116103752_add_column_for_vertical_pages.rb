class AddColumnForVerticalPages < ActiveRecord::Migration
  def change
    add_column :subjects, :good_to_know, :text
    add_column :subjects, :needed_meterial, :text
    add_column :subjects, :tips, :text

    add_column :city_subject_infos, :where_to_practice, :text
    add_column :city_subject_infos, :where_to_suit_up, :text
    add_column :city_subject_infos, :average_price, :text
    add_column :city_subject_infos, :tips, :text
  end
end
