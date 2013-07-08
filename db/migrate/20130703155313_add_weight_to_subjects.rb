# encoding: utf-8
class AddWeightToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :position, :integer
  end
end
