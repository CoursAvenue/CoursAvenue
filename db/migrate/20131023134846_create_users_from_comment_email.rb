class CreateUsersFromCommentEmail < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Student.count
    Student.find_each do |student|
      bar.increment!
      student_email = student.email
      if User.where(email: student_email).empty?
        if (comment = Comment.where{email == student_email}.first).nil?
          user = User.new email: student.email
        else
          user = User.new email: student.email, name: comment.author_name
          user.comments << comment
        end
      else
        user = User.where(email: student_email).first
      end
      if student.structure
        user.structures << student.structure
        user.subjects   << student.structure.subjects
        if student.email_status.present?
          comment_notification            = user.comment_notifications.build(structure: student.structure)
          comment_notification.status     = student.email_status
          comment_notification.updated_at = student.updated_at
        end
      end
      user.save(validate: false)
      comment_notification.save if comment_notification
      student.destroy
    end
  end

  def down
  end
end
