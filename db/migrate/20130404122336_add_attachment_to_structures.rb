class AddAttachmentToStructures < ActiveRecord::Migration
  def change
    add_attachment :structures, :image
  end
end
