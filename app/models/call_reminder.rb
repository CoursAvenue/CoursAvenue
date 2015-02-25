# encoding: utf-8
class CallReminder < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :name, :phone_number, :website, :status

  scope :archived    , -> { where( status: 'archived' ) }
  scope :not_archived, -> { where( arel_table[:status].not_eq('archived').or(
                                   arel_table[:status].eq(nil)) ) }
end
