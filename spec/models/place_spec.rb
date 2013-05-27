# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Place do
  let(:place)     { FactoryGirl.create(:place) }
  let(:structure) { place.structure }
  subject {place}

  it { should be_valid }

  it { place.to_gmap_json[:lat].should eq place.latitude }
  it { place.to_gmap_json[:lng].should eq place.longitude }

  context 'friendly_id' do
    it 'should have slug' do
      place.slug.should_not be_nil
    end

    it 'should change slug with name' do
      initial_slug = place.slug
      place.name += ' new slug'
      place.save
      place.slug.should_not eq initial_slug
    end
  end

  describe :contact do
    it 'structure if nil?' do
      admin = FactoryGirl.build(:admin)
      structure.admins << admin

      place.contact_email.should        eq admin.email
      place.contact_name.should         eq admin.name
      place.contact_phone.should        eq admin.phone_number
      place.contact_mobile_phone.should eq admin.mobile_phone_number

      place.contact_email         = 'email@test.com'
      place.contact_name          = 'Random name'
      place.contact_phone         = '01201230123012'
      place.contact_mobile_phone  = '01201230123012'

      place.contact_email.should        eq 'email@test.com'
      place.contact_name.should         eq 'Random name'
      place.contact_phone.should        eq '01201230123012'
      place.contact_mobile_phone.should eq '01201230123012'
    end
  end

  context 'without description' do
    it 'uses structure description' do
      place.description           = nil
      structure.description = Forgery(:lorem_ipsum).words(10)
      place.description.should be structure.description
    end
  end

  context 'with description' do
    it 'uses self description' do
      description       = Forgery(:lorem_ipsum).words(10)
      place.description = description
      place.description.should eq description
    end
  end

  context 'name is same as structure' do
    it 'does not repeat name' do
      place.name = place.structure.name
      place.long_name.should be place.name
    end
  end

  context 'name is different from structure name' do
    it 'includes structure name' do
      place.name = 'something else'
      place.long_name.should include place.structure.name
      place.long_name.should include place.name
    end
  end

  context 'comments' do
    it 'should have his structure comments' do
      place.structure.comments.create FactoryGirl.attributes_for(:comment)
      place.structure.comments.create FactoryGirl.attributes_for(:comment)
      place.comments.should eq place.structure.comments
    end
  end
end
