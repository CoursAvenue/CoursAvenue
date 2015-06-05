# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Admin do
  subject { FactoryGirl.create(:admin) }

  describe '#mailboxer_email' do
    it { expect(subject.mailboxer_email(nil)).to eq(subject.email) }
  end

  describe '#avatar' do
    let(:structure) { subject.structure }

    it "returns its structure's logo url" do
      expect(subject.avatar).to eq(structure.logo.thumb.url)
    end
  end

  describe '#avatar_url' do
    let(:structure) { subject.structure }
    let(:format) { %w(original large thumb small_thumb thumbnail_email_cropped).sample.to_sym }

    it "returns its structure's logo url depending on the format" do
      expect(subject.avatar_url(format)).to eq(structure.logo.url(format))
    end
  end

  describe '#name' do
    context 'with a structure' do
      let(:structure) { subject.structure }

      it "returns its structure's name" do
        expect(subject.name).to eq(structure.name)
      end
    end

    context 'without a structure' do
      before do
        subject.structure = nil
        subject.save
      end

      it 'returns its own name' do
        expect(subject.name).to eq(subject.read_attribute(:name))
      end
    end
  end

  describe '.from_omniauth' do
    context 'the admin already exists' do
      subject         { FactoryGirl.create(:admin_from_facebook) }
      let(:auth)      { create_oauth(uid: subject.uid) }
      let(:structure) { subject.structure }

      it 'returns the existing admin' do
        expect(Admin.from_omniauth(auth, structure)).to eq(subject)
      end
    end

    context "the admin doesn't exist" do
      let(:auth)      { create_oauth }
      let(:structure) { FactoryGirl.create(:structure) }

      it 'rejects an admin without structure' do
        expect(Admin.from_omniauth(auth, nil)).to be_nil
      end

      it 'creates a new admin' do
        expect { Admin.from_omniauth(auth, structure) }.to change { Admin.count }.by(1)
      end

      context 'when there are no emails in the oauth infos' do
        let(:auth) { create_oauth }

        it 'creates the admin without an email' do
          auth.info.email = nil
          admin = Admin.from_omniauth(auth, structure)
          expect(admin.email).to be_empty
        end
      end
    end
  end

  describe '#from_facebook?' do
    context 'not from facebook' do
      subject { FactoryGirl.create(:admin) }
      it { expect(subject.from_facebook?).to be_falsy }
    end

    context 'from facebook' do
      subject { FactoryGirl.create(:admin_from_facebook) }
      it { expect(subject.from_facebook?).to be_truthy }
    end
  end

  describe '#facebook_pages' do
    context 'is from facebook' do
      subject { FactoryGirl.create(:admin_from_facebook) }

      before do
        allow(FbGraph::User).to receive(:me).and_return(FbUser.new)
      end

      it 'should return the Facebook pages administrated by the admin' do
        expect(subject.facebook_pages).not_to be_empty
      end
    end

    context 'is not from facebook' do
      subject { FactoryGirl.create(:admin) }

      it "doesn't return anything" do
        expect(subject.facebook_pages).to be_empty
      end
    end
  end
end

def create_oauth(options = { uid: Faker::Number.number(6) })
  OmniAuth.config.add_mock(
    :facebook,
    uid: options[:uid],
    info: {
      email: Faker::Internet.email
    },
    credentials: {
      token: Faker::Internet.password,
      expires_at: 2.days.from_now.to_i
    }
  )
end

class Accounts < Struct.new(:name, :link); end
class FbUser
  def fetch
    self
  end

  def accounts
    [Accounts.new('CA', 'http://facebook.com/CoursAvenue')]
  end
end
