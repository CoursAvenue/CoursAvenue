# encoding: utf-8
class CallReminder < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :name, :phone_number, :website, :status, :comment

  scope :archived    , -> { where( status: 'archived' ) }
  scope :not_archived, -> { where( arel_table[:status].not_eq('archived').or(
                                   arel_table[:status].eq(nil)) ) }
  after_create :send_email_to_intercom

  private

  def send_email_to_intercom
    SuperAdminMailer.new_call_reminder_arrived(self)
  end
end
