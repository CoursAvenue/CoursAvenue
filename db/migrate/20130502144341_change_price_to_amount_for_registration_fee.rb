class ChangePriceToAmountForRegistrationFee < ActiveRecord::Migration
  def change
    rename_column :registration_fees, :price, :amount
  end
end
