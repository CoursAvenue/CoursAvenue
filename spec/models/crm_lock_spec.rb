require 'rails_helper'

RSpec.describe CrmLock, type: :model do
  context 'association' do
    it { should belong_to(:structure) }
  end

  context 'validations' do
    it { validate_presence_of(:locked) }
    it { validate_presence_of(:structure) }
  end

  describe '#lock!' do
    context 'when not lock' do
      subject { FactoryGirl.create(:crm_lock, :unlocked) }

      it 'locks' do
        subject.lock!
        expect(subject.locked?).to be_truthy
      end

      it 'updates the last locked at' do
        expect { subject.lock! }.to change { subject.locked_at }
      end
    end

    context 'when lock' do
      subject { FactoryGirl.create(:crm_lock, :locked) }

      it 'does nothing' do
        expect { subject.lock! }.to_not change { subject.locked? }
      end
    end
  end

  describe '#unlock!' do
    subject { FactoryGirl.create(:crm_lock, :unlocked) }

    context 'when not lock' do
      it 'doesn nothing' do
        expect { subject.unlock! }.to_not change { subject.locked? }
      end
    end
  end

  context 'when lock' do
    subject { FactoryGirl.create(:crm_lock, :locked) }

    it 'unlocks' do
      subject.unlock!
      expect(subject.locked?).to be_falsy
    end
  end
end
