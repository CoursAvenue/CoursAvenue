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

  context :subjects do
    before do
      @structure = FactoryGirl.build(:structure)
    end
    it 'creates courses depending the subjects passed' do
      natation = Subject.first
      @structure.subjects << natation
      @structure.save
      @structure.courses.length.should eq 1
      @structure.courses.first.name.should eq natation.name
    end
  end
  context :comments do
    it 'retrieves course comments' do
      comment = structure.comments.create FactoryGirl.attributes_for(:comment)
      structure.all_comments.should include comment
    end

    it 'updates comments_count' do
      @structure = FactoryGirl.create(:structure)
      @course    = FactoryGirl.create(:course, structure_id: @structure.id)

      FactoryGirl.create(:structure_comment, commentable_id: @structure.id, commentable_type: 'Structure')
      @structure.comments_count.should eq 1
      FactoryGirl.create(:course_comment, commentable_id: @course.id, commentable_type: 'Structure')
      @structure.comments_count.should eq 2
      FactoryGirl.create(:course_comment, commentable_id: @course.id, commentable_type: 'Structure')
      @structure.comments_count.should eq 3
    end
  end
end
