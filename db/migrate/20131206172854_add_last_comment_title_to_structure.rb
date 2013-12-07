class AddLastCommentTitleToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :last_comment_title, :string

    Structure.find_each do |structure|
      structure.update_column(:last_comment_title, structure.comments.accepted.first.title) if structure.comments.accepted.any?
    end
  end
end
