class AddFacebookLoginToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :provider, :string
    add_column :admins, :uid, :string
    add_column :admins, :oauth_token, :string
    add_column :admins, :oauth_expires_at, :datetime
  end
end
