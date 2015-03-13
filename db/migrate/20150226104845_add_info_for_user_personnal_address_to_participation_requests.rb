class AddInfoForUserPersonnalAddressToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :street  , :string
    add_column :participation_requests, :zip_code, :string
    add_column :participation_requests, :city_id , :integer
  end
end
