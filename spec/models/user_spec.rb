# -*- encoding : utf-8 -*-
require 'spec_helper'

describe User do
  context :active do
    it 'should not have password' do
      user = User.new first_name: 'Lorem', last_name: 'last_name', email: 'random@email.com'
      expect(user.password).to eq nil
      expect(user.active?).to eq false
    end
  end

  describe '#participate_to?' do
    let (:participation) { FactoryGirl.create(:participation) }

    it 'does not' do
      expect(subject.participate_to?(Planning.new)).to be(false)
    end

    it 'participates' do
      expect(participation.user.participate_to?(participation.planning)).to be(true)
    end

    it 'has canceled his participations' do
      participation.update_column :canceled_at, Time.now
      expect(participation.user.participate_to?(participation.planning)).to be(false)
    end
  end

  describe '#merge' do
    before do
      User.delete_all
    end

    let(:new_user) { FactoryGirl.create(:user) }
    let(:old_user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    it 'deletes the old user' do
      new_user.merge(old_user)
      expect(old_user.persisted?).to eq false
    end

    it 'merges the comment_notifications' do
      comment_notification         = FactoryGirl.build(:comment_notification, user: old_user)
      old_user.comment_notifications << comment_notification
      new_user.merge(old_user)
      new_user.comment_notifications.should include comment_notification
    end

    it 'merges the comments' do
      comment         = FactoryGirl.create(:comment_review)
      old_user.comments << comment
      new_user.merge(old_user)
      new_user.comments.should include comment
    end

    it 'merges the messages' do
      receipt      = other_user.send_message(old_user, 'lala', 'lili')
      conversation = receipt.conversation
      new_user.merge(old_user)
      new_user.mailbox.conversations.should include conversation
    end
  end

  describe '#participate_to?' do
    let(:user) { FactoryGirl.create(:user) }
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
end
