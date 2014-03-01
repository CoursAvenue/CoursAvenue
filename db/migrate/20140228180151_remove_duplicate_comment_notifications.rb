class RemoveDuplicateCommentNotifications < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Structure.count
    puts "Before : #{CommentNotification.count}"
    Structure.find_each do |structure|
      bar.increment!
      structure.comment_notifications.find_each do |comment_notification|
        if (notifs = structure.comment_notifications.where(structure_id: comment_notification.structure_id, user_id: comment_notification.user_id)).count > 1
          notifs[1..notifs.length - 1].map(&:delete)
        end
      end
      GC.start
    end
    puts "After : #{CommentNotification.count}"
  end

  def down
  end
end
