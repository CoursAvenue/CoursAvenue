class ApproveExistingMessageThreads < ActiveRecord::Migration
  def up
    Community::MessageThread.update_all(approved: true)
  end

  def down
    Community::MessageThread.update_all(approved: nil)
  end
end
