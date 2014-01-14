class AddAttachmentLittleImageToSubjects < ActiveRecord::Migration
  def change
    add_attachment :subjects, :small_image
  end
end
