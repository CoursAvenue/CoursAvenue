# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Structure do
  subject {structure}
  let(:structure) { FactoryGirl.create(:structure) }

  it {should be_valid}
  it {structure.active.should be true}

  context :contact do
    it 'returns admin contact' do
      admin = FactoryGirl.build(:admin)
      admin.structure_id = structure.id
      structure.admins << admin

      structure.contact_email.should == admin.email
      structure.contact_name.should  == admin.name
      structure.main_contact.should  == admin
    end
  end

  context :activate do
    it 'activates' do
      structure.active = false
      structure.activate!
      structure.active.should be_true
    end
  end

  context :disable do
    it 'disables' do
      FactoryGirl.create(:course, structure: structure)
      courses = structure.courses
      structure.active = true
      structure.disable!
      structure.active.should be_false
      courses.each{ |c| c.active.should be_false }
    end
  end

  context :destroy do
    it 'destroys everything' do
      places = structure.places
      structure.destroy
      structure.destroyed?.should be_true
      places.each{ |p| p.destroyed?.should be_true }
    end
  end

  context :address do
    it 'includes street' do
      structure.address.should include structure.street
    end
    it 'includes city' do
      structure.address.should include structure.city.name
    end
  end

  context :website do
    it 'adds the http://' do
      structure.website = 'coursavenue.com'
      structure.save
      structure.website.should eq 'http://coursavenue.com'
    end

    it 'does not add the http:// if it exists' do
      structure.website = 'http://coursavenue.com'
      structure.save
      structure.website.should eq 'http://coursavenue.com'
    end
  end

  context :comments do
    it 'retrieves course comments' do
      comment = structure.comments.create FactoryGirl.attributes_for(:comment)
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

  context :bulk_actions do
    class Structure
      def some_work(profile, number, symbol, range)
      end
    end

    before do
      ["bob@email.com", "paul@email.com", "jill@email.com"].each do |email|
        structure.user_profiles.create(email: email);
      end
    end

    let(:ids) { structure.user_profiles.to_a.map(&:id) }

    it "calls the given method, with the correct args" do
      # with block
      expect(structure).to receive(:some_work).exactly(3) do |arg1, *args|
        expect(arg1).to be_an_instance_of(UserProfile)
        expect(args).to eq(["1", :cat, (1..2)])
      end

      structure.perform_bulk_user_profiles_job(ids, :some_work, "1", :cat, (1..2))
    end

    describe :add_tags_on do
      let(:structure) { FactoryGirl.create(:structure_with_user_profiles_with_tags) }
      let(:user_profile) { structure.user_profiles.first }
      let(:tags) { ['Master of the Arts', 'powerful', 'brazen', 'churlish'] }

      it "adds the given tags to the given profile" do
        length = user_profile.tags.length

        user_profile.reload
        structure.add_tags_on(user_profile, tags)
        user_profile.reload
        expect(user_profile.tags.length).to eq(length + tags.length)
      end

      it "does not overwrite the existing tags"
      it "does not create duplicate tags"

    end

    describe :create_tag do
      let(:structure) { FactoryGirl.create(:structure) }
      it "creates a new tag" do
        length = structure.owned_tags.length
        structure.create_tag(Faker::Name.name)
        expect(structure.owned_tags.length).to eq (length + 1)
      end
    end
  end

  describe '#create_user_profile_for_message' do
    let(:structure) { FactoryGirl.create(:structure) }
    let(:user)      { FactoryGirl.create(:user) }
    before do
      @user_profile_count = structure.user_profiles.count
      structure.create_user_profile_for_message(user)
    end
    it "creates a user profile" do
      expect(structure.user_profiles.length).to eq (@user_profile_count + 1)
    end
    it "affects tag to the user profile" do
      expect(structure.user_profiles.last.tags.map(&:name)).to include UserProfile::DEFAULT_TAGS[:contacts]
    end

  context :funding_types do
    context :getters do
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
    context :setters do
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
    it 'is incomplete_profile' do
      structure.stub(:profile_completed?) { false }
      structure.update_email_status
      expect(structure.email_status).to eq 'incomplete_profile'
    end

    it 'is no_recommendations' do
      structure.stub(:profile_completed?) { true }
      structure.comments_count = 0
      structure.update_email_status
      expect(structure.email_status).to eq 'no_recommendations'
    end

    it 'is less_than_five_recommendations' do
      structure.stub(:profile_completed?) { true }
      structure.comments_count = 3
      structure.update_email_status
      expect(structure.email_status).to eq 'less_than_five_recommendations'
    end

    it 'is planning_outdated' do
      structure.stub(:profile_completed?) { true }
      structure.comments_count = 12
      structure.update_email_status
      expect(structure.email_status).to eq 'planning_outdated'
    end

    it 'is less_than_fifteen_recommendations' do
      structure.stub(:profile_completed?) { true }
      structure.comments_count = 12
      structure.courses = [FactoryGirl.create(:course)]
      structure.update_email_status
      expect(structure.email_status).to eq 'less_than_fifteen_recommendations'
    end
  end

  describe '#update_email_status' do

  end
end
