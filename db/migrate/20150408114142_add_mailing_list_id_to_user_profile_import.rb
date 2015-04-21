class AddMailingListIdToUserProfileImport < ActiveRecord::Migration
  def change
    add_reference :user_profile_imports, :newsletter_mailing_list, index: true
  end
end
