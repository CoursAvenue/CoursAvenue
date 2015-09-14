require 'rails_helper'

RSpec.describe Structure::IndexableLock, type: :model do
  context 'association' do
    it { should belong_to(:structure) }
  end

  context 'validations' do
    it { validate_presence_of(:locked) }
    it { validate_presence_of(:structure) }
  end

  describe '#lock!' do
    context 'when not lock' do
      subject { FactoryGirl.create(:structure_indexable_lock, :unlocked) }

      it 'locks' do
        subject.lock!
        expect(subject.locked?).to be_truthy
      end

      it 'updates the last locked at' do
        expect { subject.lock! }.to change { subject.locked_at }
      end
    end

    context 'when lock' do
      subject { FactoryGirl.create(:structure_indexable_lock, :locked) }

      it 'does nothing' do
        expect { subject.lock! }.to_not change { subject.locked? }
      end
    end
  end

  describe '#unlock!' do
    subject { FactoryGirl.create(:structure_indexable_lock, :unlocked) }

    context 'when not lock' do
      it 'doesn nothing' do
        expect { subject.unlock! }.to_not change { subject.locked? }
      end
    end

    context 'when lock' do
      subject { FactoryGirl.create(:structure_indexable_lock, :locked) }

      it 'unlocks' do
        subject.unlock!
        expect(subject.locked?).to be_falsy
      end
    end
  end

  describe 'too_old?' do
    context 'when the lock is unlocked' do
      subject { FactoryGirl.build_stubbed(:structure_indexable_lock, :unlocked) }
      it { expect(subject.too_old?).to be_falsy }
    end

    context 'when it has been less than a day ago' do
      subject { FactoryGirl.build_stubbed(:structure_indexable_lock, locked_at: 1.hour.ago) }
      it { expect(subject.too_old?).to be_falsy }
    end

    it 'returns true' do
      lock = FactoryGirl.build_stubbed(:structure_indexable_lock, :locked, locked_at: 2.days.ago)
      expect(lock.too_old?).to be_truthy
    end
  end
end
