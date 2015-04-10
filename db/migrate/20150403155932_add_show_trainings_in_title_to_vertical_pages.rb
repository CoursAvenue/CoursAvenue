class AddShowTrainingsInTitleToVerticalPages < ActiveRecord::Migration
  def change
    add_column :vertical_pages, :show_trainings_in_title, :boolean, default: false
  end
end
