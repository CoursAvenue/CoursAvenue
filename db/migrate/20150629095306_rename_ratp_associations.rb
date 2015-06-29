class RenameRatpAssociations < ActiveRecord::Migration
  def change
    rename_column :ratp_positions, :metro_line_id, :ratp_line_id
    rename_column :ratp_positions, :metro_stop_id, :ratp_stop_id

    # remove_index :ratp_positions, name: 'index_ratp_positions_on_metro_line_id_and_metro_stop_id'
    # remove_index :ratp_positions, name: 'index_ratp_positions_on_metro_line_id'
    # remove_index :ratp_positions, name: 'index_ratp_positions_on_metro_stop_id'
    #
    # add_index :ratp_positions, [:ratp_line_id, :ratp_stop_id]
    # add_index :ratp_positions, :ratp_line_id
    # add_index :ratp_positions, :ratp_stop_id
  end
end
