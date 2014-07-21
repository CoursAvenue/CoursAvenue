class AddAttachmentToVerticalPages < ActiveRecord::Migration
  def change
    add_attachment :vertical_pages, :image
  end
end
