# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Structure do
  subject {structure}
  let(:structure) { FactoryGirl.create(:structure) }

  it {should be_valid}
  it {should have(1).place}
  it {structure.active.should be true}

  context :contact do
    it 'should be admin' do
      admin = FactoryGirl.build(:admin)
      structure.admins << admin

      structure.contact_email.should be admin.email
      structure.contact_name.should  be admin.name
      structure.main_contact.should  be admin
    end
  end

  context :address do
    it 'should show street' do
      structure.address.should include structure.street
    end
    it 'should show city' do
      structure.address.should include structure.city.name
    end
  end

  context :comments do
    it 'should retrieve course comments' do
      comment = structure.comments.create FactoryGirl.attributes_for(:comment)

      structure.all_comments.should include comment
    end
  end
end
