class AddSubtitleToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :subtitle, :text
  end
end
