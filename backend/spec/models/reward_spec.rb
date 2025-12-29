require 'rails_helper'

RSpec.describe Reward, type: :model do
  describe 'validations' do
    subject { build(:reward) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it 'requires a cost' do
      subject.cost = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:cost]).to include("can't be blank")
    end

    it 'requires cost to be greater than zero' do
      subject.cost = 0
      expect(subject).not_to be_valid
      expect(subject.errors[:cost]).to include("must be greater than 0")

      subject.cost = -100
      expect(subject).not_to be_valid
      expect(subject.errors[:cost]).to include("must be greater than 0")
    end

    it 'allows positive cost' do
      subject.cost = 500
      expect(subject).to be_valid
    end

    it 'requires stock_quantity to be non-negative when present' do
      subject.stock_quantity = -1
      expect(subject).not_to be_valid
      expect(subject.errors[:stock_quantity]).to include("must be greater than or equal to 0")
    end

    it 'allows stock_quantity to be zero' do
      subject.stock_quantity = 0
      expect(subject).to be_valid
    end

    it 'allows stock_quantity to be nil' do
      subject.stock_quantity = nil
      expect(subject).to be_valid
    end
  end

  describe 'associations' do
    it 'has many redemptions' do
      association = described_class.reflect_on_association(:redemptions)
      expect(association.macro).to eq :has_many
    end

    it 'destroys associated redemptions when destroyed' do
      reward = create(:reward)
      create_list(:redemption, 3, reward: reward)
      expect { reward.destroy }.to change { Redemption.count }.by(-3)
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns only active rewards' do
        active_reward1 = create(:reward, active: true)
        active_reward2 = create(:reward, active: true)
        inactive_reward = create(:reward, active: false)

        active_rewards = Reward.active

        expect(active_rewards).to include(active_reward1, active_reward2)
        expect(active_rewards).not_to include(inactive_reward)
      end
    end
  end

  describe 'default values' do
    it 'sets default active to true if not provided' do
      reward = Reward.new(name: 'Test Reward', cost: 500, category: 'Gift Card')
      expect(reward.active).to eq(true)
    end
  end
end
