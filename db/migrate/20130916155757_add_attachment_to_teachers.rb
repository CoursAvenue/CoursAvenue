class AddAttachmentToTeachers < ActiveRecord::Migration
  def change
    add_attachment :teachers, :image
  end
end
