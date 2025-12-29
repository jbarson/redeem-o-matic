require 'rails_helper'

RSpec.describe Redemption, type: :model do
  describe 'validations' do
    let(:user) { create(:user) }
    let(:reward) { create(:reward) }
    subject { build(:redemption, user: user, reward: reward) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires a user_id' do
      subject.user = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:user]).to include("must exist")
    end

    it 'requires a reward_id' do
      subject.reward = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:reward]).to include("must exist")
    end

    it 'requires points_spent' do
      subject.points_spent = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:points_spent]).to include("can't be blank")
    end

    it 'requires points_spent to be greater than zero' do
      subject.points_spent = 0
      expect(subject).not_to be_valid
      expect(subject.errors[:points_spent]).to include("must be greater than 0")

      subject.points_spent = -100
      expect(subject).not_to be_valid
      expect(subject.errors[:points_spent]).to include("must be greater than 0")
    end

    it 'allows positive points_spent' do
      subject.points_spent = 500
      expect(subject).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it 'belongs to reward' do
      association = described_class.reflect_on_association(:reward)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'default values' do
    it 'sets default status to completed if not provided' do
      redemption = Redemption.new(user: create(:user), reward: create(:reward), points_spent: 500)
      expect(redemption.status).to eq('completed')
    end
  end
end
