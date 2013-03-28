class RentingRoom < ActiveRecord::Base
  belongs_to :structure

  attr_accessible :contact_phone,
                  :contact_name,
                  :contact_email,
                  :address,
                  :is_duty_free,
                  :info,
                  :maximum_price,
                  :minimum_price,
                  :name,
                  :price_info,
                  :regular_renting_price,
                  :surface,
                  :has_cloakroom,
                  :has_bars,
                  :has_mirrors,
                  :has_sound,
                  :has_carpets,
                  :has_parquet,
                  :has_recording_studio,
                  :has_piano

  validates :contact_email, :address, presence: true
end
