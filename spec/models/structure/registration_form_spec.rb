require 'rails_helper'

describe Structure::RegistrationForm do
  context 'validations' do
    it { should validate_presence_of(:structure_name) }
    it { should validate_presence_of(:structure_subjects_ids) }
    it { should validate_presence_of(:structure_subject_descendants_ids) }
    it { should validate_presence_of(:admin_email) }
    it { should validate_presence_of(:admin_password) }
    it { should validate_presence_of(:course_type) }
  end

  describe '#save' do
    context 'when not valid' do
      subject { Structure::RegistrationForm.new }

      it { expect(subject.save).to be_falsy }

      it "doesn't create the Structure" do
        expect { subject.save }.to_not change { Structure.count }
      end

      it "doesn't create the admin" do
        expect { subject.save }.to_not change { Admin.count }
      end
    end

    context 'when valid' do
      subject { Structure::RegistrationForm.new(valid_params) }

      it 'creates the Structure' do
        expect { subject.save }.to change { Structure.count }.by(1)
      end

      it 'creates the related admin' do
        expect { subject.save }.to change { Admin.count }.by(1)
      end

      it { expect(subject.save).to be_truthy }
    end
  end

  describe 'existing_admin?' do
    subject { Structure::RegistrationForm.new(valid_params) }

    context 'when the admin does not exist' do
      it { expect(subject.existing_admin?).to be_falsy }
    end

    context 'when the admin exists' do
      it 'returns the existing admin' do
        structure = FactoryGirl.create(:structure)
        structure.admin = Admin.create(structure: structure, email: subject.admin_email, password: subject.admin_password)

        expect(subject.existing_admin?).to be_truthy
      end
    end
  end
end

def valid_params
  structure_subject = FactoryGirl.create(:subject_children)
  root_subject = structure_subject.root

  {
    structure_name: Faker::Name.name + ' Institute',
    structure_subjects_ids: [root_subject.id],
    structure_subject_descendants_ids: [structure_subject.id],

    course_type: 'lesson',

    admin_email: Faker::Internet.email,
    admin_password: Faker::Internet.password
  }
end
