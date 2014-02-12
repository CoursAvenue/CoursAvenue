# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Participation do

  context :callbacks do
    let (:planning) { FactoryGirl.create(:planning) }

    describe '#welcome_email' do
      pending 'TODO'
    end

    describe '#set_waiting_list' do
      it 'set it to true' do
        planning.update_attribute(:nb_participants_max, 0)
        subject.planning             = planning
        subject.set_waiting_list
        expect(subject.waiting_list).to be_true
      end
      it 'set it to false' do
        planning.update_attribute(:nb_participants_max, 2)
        subject.planning = planning
        subject.set_waiting_list
        expect(subject.waiting_list).to be_false
      end
    end

    describe '#update_planning_participations_waiting_list' do
      it 'updates waiting_list if someone unsubscribe' do
        planning = FactoryGirl.create(:planning)
        planning.update_attribute(:nb_participants_max, 1)
        first_participation = planning.participations.create user: FactoryGirl.create(:user)
        last_participation  = planning.participations.create user: FactoryGirl.create(:user)
        first_participation.destroy
        expect(last_participation.reload.waiting_list).to be_false
      end
    end
  end
end
