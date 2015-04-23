class AddFromPersonalWebsiteToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :from_personal_website, :boolean, default: false
  end
end
