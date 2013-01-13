class CreateNewsletterUsers < ActiveRecord::Migration
  def change
    create_table :newsletter_users do |t|
      t.string :city
      t.string :email

      t.timestamps
    end
  end
end
