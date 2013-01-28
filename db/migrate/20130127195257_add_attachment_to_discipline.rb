class AddAttachmentToDiscipline < ActiveRecord::Migration
  def change
    add_attachment :disciplines, :image
  end
end
