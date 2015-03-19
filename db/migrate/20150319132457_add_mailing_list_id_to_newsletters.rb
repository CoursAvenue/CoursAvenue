class AddMailingListIdToNewsletters < ActiveRecord::Migration
  def change
    add_reference :newsletters, :newsletter_mailing_list, index: true
  end
end
