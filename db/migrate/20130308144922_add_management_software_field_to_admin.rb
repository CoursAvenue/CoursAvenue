class AddManagementSoftwareFieldToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :management_software_used, :string
  end
end
