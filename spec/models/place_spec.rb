# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Place do
  subject {place}
  let(:place) { FactoryGirl.create(:place) }

  it { should be_valid }
  it { place.to_gmap_json[:lat].should eq place.latitude }
  it { place.to_gmap_json[:lng].should eq place.longitude }

  describe :contact do
    it 'structure if nil?' do
      admin = FactoryGirl.build(:admin)
      place.structure.admins << admin

      place.contact_email.should == admin.email
      place.contact_name.should  == admin.name

      place.contact_email = 'email@test.com'
      place.contact_name  = 'Random name'

      place.contact_email.should == 'email@test.com'
      place.contact_name.should  == 'Random name'
    end
  end

  it 'should use structure description if empty' do
    place.description.should be place.structure.description
    new_desc = Forgery(:lorem_ipsum).words(10)
    place.description = new_desc
    place.description.should be new_desc
  end

  it 'should not repeat name if same as structure' do
    place.name = place.structure.name
    place.long_name.should be place.name
    place.name = 'something else'
    place.long_name.should eq place.structure.name + ' - ' +  place.name
  end

  it 'should have his structure comments' do
    place.structure.comments.create FactoryGirl.attributes_for(:comment)
    place.structure.comments.create FactoryGirl.attributes_for(:comment)
    place.comments.should eq place.structure.comments
  end
end
