class DropTableReservations < ActiveRecord::Migration
  def change
    drop_table :reservations
    drop_table :reservation_loggers
  end
end
