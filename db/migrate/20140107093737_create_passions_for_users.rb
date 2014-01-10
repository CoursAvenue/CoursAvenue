class CreatePassionsForUsers < ActiveRecord::Migration
  def up
    bar = ProgressBar.new User.count
    User.find_each do |user|
      bar.increment!
      if user.subjects.any? and user.subjects.count < 4
        user.subjects.at_depth(2).each do |child_subject|
          user.passions.create(parent_subject: child_subject.root, subject: child_subject, practiced: true)
        end
      end
    end
  end

  def down
  end
end
