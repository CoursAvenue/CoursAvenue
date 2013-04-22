class RefactoredFirstNameAndPhoneForAdmins < ActiveRecord::Migration
  def up
    add_column :admins, :name, :string
    Admin.all.each do |admin|
      admin.name         = admin.full_name
      admin.phone_number = (admin.phone_number.present? ? admin.phone_number : admin.mobile_phone_number)
      admin.save
    end
    remove_column :admins, :first_name
    remove_column :admins, :last_name
  end

  def down
    remove_column :admins, :name
    add_column    :admins, :first_name, :string
    add_column    :admins, :last_name, :string
    add_column    :admins, :mobile_phone_number, :string
  end
end
