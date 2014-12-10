# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Participation do

  subject { Participation.new }

  context 'waiting_list' do
    let (:planning) { FactoryGirl.create(:planning) }

    before do
      subject.user = FactoryGirl.create(:user)
    end

    it 'goes on waiting_list' do
      planning.update_attribute(:nb_participants_max, 0)
      subject.planning = planning
      subject.save
      expect(subject.waiting_list).to be(true)
    end

    it 'does not go on waiting_list' do
      planning.update_attribute(:nb_participants_max, 1)
      subject.planning = planning
      subject.save
      expect(subject.waiting_list).to be(false)
    end

    context 'popps_off_waiting_list' do
      before do
        # First person participate
        planning.update_attribute(:nb_participants_max, 1)
        subject.planning = planning
        subject.save
      end
      it 'pops off' do
        # Second person participate and then goes on waiting list
        participation_2          = FactoryGirl.build(:participation)
        participation_2.user     = FactoryGirl.create(:user)
        participation_2.planning = planning
        participation_2.save
        expect(participation_2.waiting_list).to be(true)
        # First person cancels
        subject.cancel!
        expect(participation_2.reload.waiting_list).to be(false)
      end

      it 'does not pops off' do
        # Second person participate and then goes on waiting list
        participation_2                   = FactoryGirl.build(:participation_for_kid_and_adult)
        participation_2.user              = FactoryGirl.create(:user)
        participation_2.planning          = planning
        participation_2.save
        expect(participation_2.waiting_list).to be(true)
        # First person cancels
        subject.cancel!
        expect(participation_2.reload.waiting_list).to be(true)
      end
    end
  end

  describe '#with_kid?' do
    it 'returns true' do
      subject.participation_for = 'participations.for.kids_and_adults'
      expect(subject.with_kid?).to be(true)
    end

    it 'returns true' do
      subject.participation_for = 'participations.for.kids'
      expect(subject.with_kid?).to be(true)
    end

    it 'returns false' do
      subject.participation_for = 'participations.for.one_aduld'
      expect(subject.with_kid?).to be(false)
    end
  end

  describe '#size' do
    it 'returns 1' do
      subject.participation_for = 'participations.for.kids'
      expect(subject.size).to eq 1
    end

    it 'returns 1' do
      subject.participation_for = 'participations.for.one_adult'
      expect(subject.size).to eq 1
    end

    it 'returns 2' do
      subject.participation_for = 'participations.for.kids_and_adults'
      subject.nb_kids           = 4
      subject.nb_adults         = 2
      expect(subject.size).to eq 6
    end
  end

  describe '#canceled?' do
    it 'returns true' do
      subject.canceled_at = Time.now
      expect(subject.canceled?).to be(true)
    end

    it 'returns false' do
      expect(subject.canceled?).to be(false)
    end
  end

  describe '#cancel!' do
    it 'update canceled_at' do
      subject.user = FactoryGirl.create(:user)
      subject.cancel!
      expect(subject.canceled_at).not_to be_nil
    end
  end

  context 'callbacks' do
    let (:planning) { FactoryGirl.create(:planning) }

    describe '#set_default_participation_for' do
      it 'sets it to one_adult' do
        subject.nb_kids   = 0
        subject.nb_adults = 1
        subject.send(:set_default_participation_for)
        expect(subject.participation_for).to eq 'participations.for.one_adult'
      end
      it 'sets it to one_kid' do
        subject.nb_kids   = 2
        subject.nb_adults = 0
        subject.send(:set_default_participation_for)
        expect(subject.participation_for).to eq 'participations.for.kids'
      end
      it 'sets it to one_kid_and_one_adult' do
        subject.nb_kids   = 2
        subject.nb_adults = 3
        subject.send(:set_default_participation_for)
        expect(subject.participation_for).to eq 'participations.for.kids_and_adults'
      end
    end

    describe '#set_waiting_list' do
      it 'set it to true' do
        planning.update_attribute(:nb_participants_max, 0)
        subject.planning             = planning
        subject.set_waiting_list
        expect(subject.waiting_list).to be(true)
      end
      it 'set it to false' do
        planning.update_attribute(:nb_participants_max, 2)
        subject.planning = planning
        subject.set_waiting_list
        expect(subject.waiting_list).to be(false)
      end
    end

    describe '#update_planning_participations_waiting_list' do
      it 'updates waiting_list if someone unsubscribe' do
        planning = FactoryGirl.create(:planning)
        planning.update_attribute(:nb_participants_max, 1)
        first_participation = planning.participations.create user: FactoryGirl.create(:user)
        last_participation  = planning.participations.create user: FactoryGirl.create(:user)
        first_participation.cancel!
        expect(last_participation.reload.waiting_list).to be(false)
      end
    end

    describe '#creates_user_profile' do
      it 'creates a user profile after a participation is made' do
        planning             = FactoryGirl.create(:planning)
        user_profiles_length = planning.structure.user_profiles.length
        participation        = planning.participations.create user: FactoryGirl.create(:user)
        expect(planning.structure.user_profiles.reload.length).to eq user_profiles_length + 1
        expect(planning.structure.user_profiles.last.tags.map(&:name)).to include UserProfile::DEFAULT_TAGS[:jpo_2014]
      end
    end
  end

  describe '#pop_from_waiting_list' do
    before :each do
      @planning             = FactoryGirl.create(:planning)
      @planning.update_attribute(:nb_participants_max, 1)
      first_participation   = @planning.participations.create user: FactoryGirl.create(:user)
      @participation        = @planning.participations.create user: FactoryGirl.create(:user)
    end

    it 'increase size of nb_participants_max of the planning' do
      initial_nb_participants_max = @planning.nb_participants_max
      @participation.pop_from_waiting_list
      expect(@planning.reload.nb_participants_max).to eq initial_nb_participants_max + 1
    end

    it 'pops the user from waiting_list' do
      @participation.pop_from_waiting_list
      expect(@participation.waiting_list).to be(false)
    end
  end
end
