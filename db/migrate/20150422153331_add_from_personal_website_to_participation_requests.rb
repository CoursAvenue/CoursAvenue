class AddFromPersonalWebsiteToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :structures, :from_personal_website, :boolean, default: false
  end
end
