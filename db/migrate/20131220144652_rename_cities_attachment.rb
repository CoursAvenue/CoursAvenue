class RenameCitiesAttachment < ActiveRecord::Migration
  def change
    remove_attachment :cities, :no_result_image
    add_attachment :cities, :image
  end
end
