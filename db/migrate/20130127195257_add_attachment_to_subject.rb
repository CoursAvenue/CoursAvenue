class AddAttachmentToSubject < ActiveRecord::Migration
  def change
    add_attachment :subjects, :image
  end
end
