class ChangeDeletedAtTimeToDatetime < ActiveRecord::Migration
  def up
    drop_table :locations
    tables = [:contacts, :courses, :medias, :participations, :places, :plannings, :price_groups, :prices, :structures, :teachers, :users, :admins, :comments]
    tables.each do |table_name|
      add_column table_name, :deleted_at_new, :datetime
    end

    models = [Contact, Course, Media, Participation, Place, Planning, PriceGroup, Price, Structure, Teacher, User, Admin, Comment]
    models.each do |model|
      model.only_deleted.find_each do |record|
        record.update_column :deleted_at_new, Time.now
      end
    end

    tables.each do |table_name|
      remove_column table_name, :deleted_at
      rename_column table_name, :deleted_at_new, :deleted_at
    end
  end

  def down
    create_table :locations
    tables = [:contacts, :courses, :medias, :participations, :places, :plannings, :price_groups, :prices, :structures, :teachers, :users, :admins, :comments]
    tables.each do |table_name|
      change_column table_name, :deleted_at, :time
    end
  end
end
