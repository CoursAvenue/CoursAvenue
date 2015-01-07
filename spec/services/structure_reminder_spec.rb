require 'rails_helper'

describe StructureReminder do
  describe '.send_status_reminder' do
    let(:structure) { FactoryGirl.create(:structure) }

    context 'structure has no main contact' do
      before do
        structure.admins = []
        structure.save
      end

      it "doesn't send the reminder" do
        expect { ReminderService.send_status_reminder(structure) }.
          to_not change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end
