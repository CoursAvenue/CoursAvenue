class RemoveAndAddColumnForSpecialFundingOnStructures < ActiveRecord::Migration
  def up
    remove_column :structures, :accepts_holiday_vouchers
    remove_column :structures, :accepts_ancv_sports_coupon
    remove_column :structures, :accepts_leisure_tickets
    remove_column :structures, :accepts_afdas_funding
    remove_column :structures, :accepts_dif_funding
    remove_column :structures, :accepts_cif_funding
    add_column    :structures, :funding_type_ids, :string
  end

  def down
    remove_column :structures, :funding_type_ids
    add_column    :structures, :accepts_holiday_vouchers, :string
    add_column    :structures, :accepts_ancv_sports_coupon, :string
    add_column    :structures, :accepts_leisure_tickets, :string
    add_column    :structures, :accepts_afdas_funding, :string
    add_column    :structures, :accepts_dif_funding, :string
    add_column    :structures, :accepts_cif_funding, :string
  end
end
