class AddExtraInfosAndCourseIdsToMailboxerMessages < ActiveRecord::Migration
  def change
    add_column :mailboxer_conversations, :mailboxer_extra_info_ids, :string
    add_column :mailboxer_conversations, :mailboxer_course_ids, :string
  end
end
