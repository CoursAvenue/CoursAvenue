class RemovePaperclipAttachmentsFromStructureAndCourses < ActiveRecord::Migration
  def change
    remove_attachment :courses, :image
    remove_attachment :structures, :image
  end
end
