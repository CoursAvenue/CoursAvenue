require 'rails_helper'

describe StructureReminder do
  describe '.send_status_reminder' do
    context 'structure has no main contact' do
      let(:structure) { FactoryGirl.create(:structure) }

      it "doesn't send the reminder" do
        expect { StructureReminder.status(structure) }.
          to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    context 'structure is sleeping' do
      let(:structure) { FactoryGirl.create(:sleeping_structure) }

      it "doesn't send the reminder" do
        expect { StructureReminder.status(structure) }.
          to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    context "structure's main contact has opted out of emails" do
      let(:structure)    { FactoryGirl.create(:structure_with_admin) }
      let(:main_contact) { structure.main_contact }

      before do
        main_contact.monday_email_opt_in = false
        main_contact.save
      end

      it "doesn't send a reminder" do
        expect { StructureReminder.status(structure) }.
          to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    context 'structure has been visited more that 15 times in the last month' do
      let(:structure)    { FactoryGirl.create(:structure_with_admin) }

      before do
        allow(Metric).to receive(:impression_count).and_return(16)
      end

      it 'sends the reminder' do
        expect { StructureReminder.status(structure) }.
          to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context "structure's profile is incomplete" do
      let (:structure) { FactoryGirl.create(:structure_with_admin) }

      it 'sends the reminder' do
        expect { StructureReminder.status(structure) }.
          to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
