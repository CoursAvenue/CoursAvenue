class ConfirmExistingUsers < ActiveRecord::Migration
  def change
    bar = ProgressBar.new User.active.count
    User.active.each do |user|
      bar.increment!
      user.confirmed_at         = user.updated_at
      user.confirmation_sent_at = user.updated_at
      user.save
    end
  end
end
