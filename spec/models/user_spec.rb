# -*- encoding : utf-8 -*-
require 'rails_helper'
require 'carrierwave/test/matchers'
require 'stripe_mock'

describe User do
  include CarrierWave::Test::Matchers

  it_behaves_like 'StripeCustomer'

  context :active do
    it 'should not have password' do
      user = User.new first_name: 'Lorem', last_name: 'last_name', email: 'random@email.com'
      expect(user.password).to eq nil
      expect(user.active?).to eq false
    end
  end

  # describe '#participate_to?' do
  #   let (:participation) { FactoryGirl.create(:participation) }
  #
  #   it 'does not' do
  #     expect(subject.participate_to?(Planning.new)).to be(false)
  #   end
  #
  #   it 'participates' do
  #     expect(participation.user.participate_to?(participation.planning)).to be(true)
  #   end
  #
  #   it 'has canceled his participations' do
  #     participation.update_column :canceled_at, Time.now
  #     expect(participation.user.participate_to?(participation.planning)).to be(false)
  #   end
  # end

  describe '#merge' do
    before do
      User.delete_all
    end

    let(:new_user) { FactoryGirl.create(:user) }
    let(:old_user) { FactoryGirl.create(:user) }
    let(:admin)    { FactoryGirl.create(:admin) }

    it 'deletes the old user' do
      new_user.merge(old_user)
      expect(old_user.deleted?).to eq true
    end

    it 'merges the comment_notifications' do
      comment_notification         = FactoryGirl.build(:comment_notification, user: old_user)
      old_user.comment_notifications << comment_notification
      new_user.merge(old_user)
      expect(new_user.comment_notifications).to include(comment_notification)
    end

    it 'merges the comments' do
      comment         = FactoryGirl.create(:comment_review)
      old_user.comments << comment
      new_user.merge(old_user)
      expect(new_user.comments).to include(comment)
    end

    it 'merges the messages' do
      receipt      = admin.send_message(old_user, 'lala', 'lili')
      conversation = receipt.conversation
      new_user.merge(old_user)
      expect(new_user.mailbox.conversations).to include(conversation)
    end
  end

  describe '#participate_to?' do
    let(:user)     { FactoryGirl.create(:user) }
    let(:planning) { FactoryGirl.create(:planning) }

    it 'returns true' do
      user.participations.create(planning: planning)
      expect(user.participate_to?(planning)).to be(true)
    end

    it 'returns false' do
      expect(user.participate_to?(planning)).to be(false)
    end
  end

  describe '#subscription_slug' do
    let (:user) { FactoryGirl.create(:user) }

    it 'returns the user slug by default' do
      expect(user.sponsorship_slug).to equal(user.slug)
    end

    it 'returns the user defined slug when defined' do
      slug = 'my-new-slug'
      user.sponsorship_slug = slug

      expect(user.sponsorship_slug).to equal(slug)
    end
  end

  # describe '#update_email_status' do
  #   let(:user) { FactoryGirl.create(:user) }

  #   it 'is passions_incomplete' do
  #     user.update_email_status
  #     expect(user.email_status).to eq 'passions_incomplete'
  #   end
  # end

  context :sponsorship do
    describe '#update_sponsorship_status' do
      let (:user)           { FactoryGirl.create(:user) }
      let (:sponsored_user) {
        user = FactoryGirl.build(:user_redux)
        user.save(validate: false)
        user
      }

      it 'should update the sponsorship on confirmation' do
        sponsorship = user.sponsorships.create(sponsored_user: sponsored_user)
        sponsored_user.confirm!

        sponsorship.reload
        expect(sponsorship.state).to eq("registered")
      end

    end
  end

  describe '.from_omniauth' do
    context 'the user already exists' do
      subject    { FactoryGirl.create(:user, :from_facebook) }
      let(:auth) { create_oauth(uid: subject.uid) }

      it 'returns the existing user' do
        expect(User.from_omniauth(auth)).to eq(subject)
      end
    end

    context "the user doesn't exists" do
      let(:auth) { create_oauth }

      it 'creates the user' do
        expect { User.from_omniauth(auth) }.to change { User.count }.by(1)
      end
    end
  end

  describe '.create_or_find_from_email' do
    context 'the user already exists' do
      let!(:user) { FactoryGirl.create(:user) }

      before do
        User.create_or_find_from_email(subject.email)
      end

      it "doesn't create a new user" do
        expect { User.create_or_find_from_email(subject.email) }.to_not change { User.count }
      end

      it 'returns the existing user' do
        expect(User.create_or_find_from_email(user.email)).to eq(user)
      end
    end

    context "the user doesn't exist" do
      let(:new_email) { Faker::Internet.email }
      let(:name)      { Faker::Name.first_name }

      it 'creates a new user' do
        expect { User.create_or_find_from_email(new_email, name) }.to change { User.count }.by(1)
      end

      it 'returns a new user' do
        expect(User.create_or_find_from_email(new_email, name)).to be_valid
      end
    end
  end

  describe '#has_avatar?' do
    context 'simple user' do
      subject { FactoryGirl.create(:user) }

      it "doesn't have an avatar" do
        expect(subject.has_avatar?).to be_falsy
      end

    end

    context 'from facebook' do
      subject { FactoryGirl.create(:user_from_facebook) }

      it 'has an avatar' do
        expect(subject.has_avatar?).to be_truthy
      end
    end

    context 'from regular inscription' do
      let(:image_url) { 'http://placehold.it/500' }
      subject         { FactoryGirl.create(:user, remote_avatar_url: image_url) }

      before do
        UserAvatarUploader.enable_processing = true
      end

      after do
        UserAvatarUploader.enable_processing = false
      end

      it 'has an avatar' do
        expect(subject.has_avatar?).to be_truthy
      end
    end
  end

  describe '#avatar_url' do
    context 'User from Facebook' do
      let(:user) { FactoryGirl.create(:user_from_facebook) }

      it 'returns the url from facebook' do
        expect(user.avatar_url).to eq(user.fb_avatar)
      end
    end

    # context 'User from the website' do
    #   before do
    #     UserAvatarUploader.enable_processing = true
    #   end
    #
    #   after do
    #     UserAvatarUploader.enable_processing = false
    #   end
    #
    #   let(:image_url) { 'http://placehold.it/500' }
    #   let(:user)      { FactoryGirl.create(:user, remote_avatar_url: image_url) }
    #
    #   it 'returns the url from the uploader' do
    #     expect(user.avatar.wide).to have_dimensions(800, 800)
    #   end
    # end

  end
end

def create_oauth(options = { uid: Faker::Number.number(6) })
  OmniAuth.config.add_mock(
    :facebook,
    uid: options[:uid],
    info: {
      email:      Faker::Internet.email,
      first_name: Faker::Name.first_name,
      last_name:  Faker::Name.last_name,
      image:      Faker::Company.logo,
      location:   'paris'
    },
    credentials: {
      token:      Faker::Internet.password,
      expires_at: 2.days.from_now.to_i
    },
    extra: {
      raw_info: {
        gender: %w(male female).sample,
      }
    }
  )
end
