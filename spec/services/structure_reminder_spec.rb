require 'rake'
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

  describe '.pending_comment' do
    context 'without comments' do
      let(:structure) { FactoryGirl.create(:structure_with_admin) }

      it "doesn't send the reminder" do
        expect { StructureReminder.pending_comments(structure) }.
          to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    context 'with pending comments' do
      let(:structure) { FactoryGirl.create(:structure_with_admin) }

      before do
        structure.comments << FactoryGirl.create(:pending_comment, commentable: structure)
      end

      it 'sends a reminder' do
        expect { StructureReminder.pending_comments(structure) }.
          to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

  describe '.widget' do
    context 'structure has no main contact' do
      let(:structure) { FactoryGirl.create(:structure) }

      it "doesn't send the reminder" do
        expect { StructureReminder.widget(structure) }.
          to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    context "structure's main contact has opted out of mails" do
      let(:structure)    { FactoryGirl.create(:structure_with_admin) }
      let(:main_contact) { structure.main_contact }

      before do
        main_contact.monday_email_opt_in = false
        main_contact.save
      end

      it "doesn't send a reminder" do
        expect { StructureReminder.widget(structure) }.
          to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    context "structure doesn't have a widget yet" do
      let(:structure) { FactoryGirl.create(:structure_with_admin) }

      it 'sends the reminder' do
        expect { StructureReminder.widget(structure) }.
          to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

  describe '.outdated_planning' do
    context 'the structure has published courses' do
      let(:course)    { FactoryGirl.create(:course) }
      let(:structure) { course.structure }

      before do
        structure.courses << course
        structure.save

        structure.reload
      end

      it "doesn't send the reminder" do
        expect { StructureReminder.outdated_planning(structure) }.
          to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    context "structure's main contact has opted out of emails" do
      let(:structure) { FactoryGirl.create(:structure_with_admin) }
      let(:main_contact) { structure.main_contact }

      before do
        main_contact.monday_email_opt_in = false
        main_contact.save
      end

      it "doesn't send the reminder" do
        expect { StructureReminder.outdated_planning(structure) }.
          to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    context 'with an outdated planning' do
      let(:structure) { FactoryGirl.create(:structure_with_admin) }
      let(:course)    { FactoryGirl.create(:course, structure: structure) }


      it 'sends the reminder' do
        expect { StructureReminder.outdated_planning(structure) }.
          to change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end
