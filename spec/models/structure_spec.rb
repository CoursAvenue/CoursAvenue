# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Structure do
  subject {structure}
  let(:structure) { FactoryGirl.create(:structure) }

  it {should be_valid}
  it {structure.active.should be true}

  context 'contact' do
    it 'returns admin contact' do
      admin = FactoryGirl.create(:admin)
      admin.structure_id = structure.id
      structure.admins << admin

      structure.contact_email.should == admin.email
      structure.contact_name.should  == admin.name
      structure.main_contact.should  == admin
    end
  end

  context 'activate' do
    it 'activates' do
      structure.active = false
      structure.activate!
      structure.active.should be(true)
    end
  end

  context 'disable' do
    it 'disables' do
      FactoryGirl.create(:course, structure: structure)
      courses = structure.courses
      structure.active = true
      structure.disable!
      structure.active.should be(false)
      courses.each{ |c| c.active.should be(false) }
    end
  end

  context 'destroy' do
    it 'destroys everything' do
      places = structure.places
      structure.destroy
      structure.destroyed?.should be(true)
      places.each{ |p| p.destroyed?.should be(true) }
    end
  end

  context 'address' do
    it 'includes street' do
      structure.address.should include structure.street
    end
    it 'includes city' do
      structure.address.should include structure.city.name
    end
  end

  context 'comments' do
    it 'retrieves course comments' do
      comment = structure.comments.create FactoryGirl.attributes_for(:comment_review)
      structure.comments.should include comment
    end
  end

  it 'updates comments_count' do
    @structure = FactoryGirl.create(:structure)
    FactoryGirl.create(:accepted_comment, commentable_id: @structure.id, commentable_type: 'Structure')
    @structure.reload.comments_count.should eq 1
    FactoryGirl.create(:accepted_comment, commentable_id: @structure.id, commentable_type: 'Structure')
    @structure.reload.comments_count.should eq 2
    FactoryGirl.create(:accepted_comment, commentable_id: @structure.id, commentable_type: 'Structure')
    @structure.reload.comments_count.should eq 3
  end

  context 'tagging' do

    describe 'add_tags_on' do
      let(:structure) { FactoryGirl.create(:structure_with_user_profiles_with_tags) }
      let(:user_profile) { structure.user_profiles.first }
      let(:tags) { ['Master of the Arts', 'powerful', 'brazen', 'churlish'] }

      it "adds the given tags to the given profile" do
        pending("This test still behaves poorly, even though the same test works both online and in the console.")
        length = user_profile.tags.length

        user_profile.reload
        structure.add_tags_on(user_profile, tags)
        user_profile.reload

        expect(user_profile.tags.length).to eq(length + tags.length)
      end

      # it "does not overwrite the existing tags"
      # it "does not create duplicate tags"

    end

    describe 'create_tag' do
      let(:structure) { FactoryGirl.create(:structure) }
      it "creates a new tag" do
        length = structure.owned_tags.length
        structure.create_tag(Faker::Name.name)
        expect(structure.owned_tags.length).to eq (length + 1)
      end
    end
  end

  context 'funding_types' do
    context 'getters' do
      describe '#funding_types' do
        it 'returns FundingTypes' do
          structure.funding_types = [FundingType.first]
          expect(structure.funding_types).to eq [FundingType.first]
        end
      end
      describe '#funding_type_ids' do
        it 'returns an array of ids' do
          structure.funding_types = [FundingType.first]
          expect(structure.funding_type_ids).to eq [FundingType.first.id]
        end
      end
    end
    context 'setters' do
      describe '#funding_type_ids=' do
        it 'stores ids if given an array of ids' do
          structure.funding_type_ids = [1, 2]
          expect(structure.read_attribute(:funding_type_ids)).to eq '1,2'
        end

        it 'stores ids if given a string' do
          structure.funding_type_ids = '1,2'
          expect(structure.read_attribute(:funding_type_ids)).to eq '1,2'
        end
      end

      describe '#funding_type=' do
        it 'stores ids if given an array of FundingType' do
          structure.funding_types = [FundingType.first, FundingType.last]
          expect(structure.read_attribute(:funding_type_ids)).to eq "#{FundingType.first.id},#{FundingType.last.id}"
        end

        it 'stores ids if given an array of ids' do
          structure.funding_types = FundingType.first
          expect(structure.read_attribute(:funding_type_ids)).to eq FundingType.first.id.to_s
        end
      end
    end
  end

  describe '#profile_completed' do
    it 'has no logo' do
      structure.stub(:profile_completed?) { false }
      structure.update_email_status
      expect(structure.email_status).to eq 'incomplete_profile'
    end

    context 'logo_stubbed' do
      def stub_logo(structure)
        structure.stub(:logo_file_name) { 'lala' }
        structure.stub(:logo_content_type) { 'type/jpg' }
        structure.stub(:logo_file_size) { 12412 }
        structure.stub(:logo_updated_at) { Time.now }
      end

      it 'is incomplete_profile' do
        stub_logo(structure)
        structure.stub(:profile_completed?) { false }
        structure.update_email_status
        expect(structure.email_status).to eq 'incomplete_profile'
      end
    end
  end

  describe '#highlighted_comment' do
    it 'returns highlighted_comment' do
      comment = structure.comments.create FactoryGirl.attributes_for(:comment_review)
      subject.stub(:highlighted_comment_id) { comment.id }
      expect(subject.highlighted_comment_id).to be comment.id
    end
  end

  describe '#highlight_comment!' do
    it 'sets highlighted_comment_id' do
      comment = structure.comments.create FactoryGirl.attributes_for(:comment_review)
      subject.highlight_comment! comment
      expect(subject.highlighted_comment_id).to be comment.id
    end
  end

  describe '#strip_name' do
    it 'removes end spaces' do
      subject.name = ' test name '
      subject.save
      expect(subject.name).to eq 'test name'
    end
  end

  describe '#reset_cropping_attributes' do
    it 'sets to 0 attributes' do
      subject.crop_width = 1
      subject.crop_x     = 1
      subject.crop_y     = 1
      subject.send :reset_cropping_attributes
      expect(subject.crop_width).to eq 0
      expect(subject.crop_x).to     eq 0
      expect(subject.crop_y).to     eq 0
    end
  end

  context 'validations' do
    describe '#no_contacts_in_name' do
      it 'has errors on name' do
        subject.name = "www.test.com"
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages).to include :name
      end
    end

    describe '#subject_parent_and_children' do
      it "doesn't have any subjects" do
        subject.subjects = []
        subject.valid?
        expect(subject.errors.messages).to include :subjects
        expect(subject.errors.messages).to include :children_subjects
      end

      it "doesn't have child subjects" do
        subject.subjects = [Subject.roots.first]
        subject.valid?
        expect(subject.errors.messages).not_to include :subjects
        expect(subject.errors.messages).to include :children_subjects
      end
    end

    describe '#reject_places' do
      it 'rejects it' do
        expect(subject.send(:reject_places, { zip_code: '' })).to be(true)
      end

      it 'does not rejects it' do
        expect(subject.send(:reject_places, { zip_code: '75014' })).to be(false)
      end
    end

    describe '#reject_phone_number' do
      it 'rejects it' do
        expect(subject.send(:reject_phone_number, { number: '' })).to be(true)
      end

      it 'does not rejects it' do
        expect(subject.send(:reject_phone_number, { number: '04102401240' })).to be(false)
      end

      it 'destroys it' do
        attributes = { id: 4,  number: '' }
        subject.send :reject_phone_number, attributes
        expect(attributes[:_destroy]).to eq 1
      end
    end
  end

  context 'sleeping' do
    describe 'duplicate_structure' do

      let(:structure)            { FactoryGirl.create(:sleeping_structure) }

      # We start the spec by reloading the spec so it is created at that moment
      # and not when we access it for the first time in the assertion.
      it 'creates a new structure' do
        structure.reload

        expect { structure.duplicate_structure }.to change { Structure.count }.by(1)
      end

      it "doesn't create two new structures" do
        structure.duplicate_structure

        expect { structure.duplicate_structure }.to_not change { Structure.count }
      end

      it 'associates the new structure with the current structure' do
        sleeping_structure = structure.duplicate_structure

        expect(sleeping_structure).to_not be_nil
        expect(sleeping_structure.controled_structure).to eq structure
      end

      it 'makes the current structure inactive' do
        structure.duplicate_structure

        expect(structure.active).to be false
      end

      it 'makes the new structure active' do
        structure.duplicate_structure

        expect(structure.sleeping_structure.active).to be true
      end
    end

    describe 'wake_up!' do
      let(:structure)            { FactoryGirl.create(:sleeping_structure) }
      let(:admin)                { FactoryGirl.create(:admin) }
      let(:sleeping_structure)   { structure.duplicate_structure }

      before(:each) do
        admin.structure = structure
        structure.admins << admin

        admin.save
        structure.save

        sleeping_structure.reload
      end

      it 'wakes itself' do
        structure.wake_up!

        expect(structure.is_sleeping).to be false
      end

      it 'activates itself' do
        structure.wake_up!

        expect(structure.active).to be true
      end

      it 'deactivates the duplicated structure' do
        structure.wake_up!

        expect(sleeping_structure.is_sleeping).to be true
      end

      it 'puts the duplicated structure to sleep' do
        structure.wake_up!

        expect(sleeping_structure.active).to be false
      end
    end
  end

end
