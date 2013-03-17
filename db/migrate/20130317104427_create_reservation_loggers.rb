class CreateReservationLoggers < ActiveRecord::Migration
  def change
    create_table :reservation_loggers do |t|
      t.references :course
      t.timestamps
    end
  end
end
