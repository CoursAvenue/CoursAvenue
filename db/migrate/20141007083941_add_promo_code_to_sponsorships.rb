class AddPromoCodeToSponsorships < ActiveRecord::Migration
  def change
    add_column :sponsorships, :promo_code, :string
  end
end
