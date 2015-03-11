class AddMailingListToUserProfiles < ActiveRecord::Migration
  def change
    add_reference :user_profiles, :newsletter_mailing_list, index: true
  end
end
