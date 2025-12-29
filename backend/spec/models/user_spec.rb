require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires an email' do
      subject.email = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("can't be blank")
    end

    it 'requires a unique email' do
      create(:user, email: 'test@example.com')
      subject.email = 'test@example.com'
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("has already been taken")
    end

    it 'requires a name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it 'requires points_balance to be non-negative' do
      subject.points_balance = -100
      expect(subject).not_to be_valid
      expect(subject.errors[:points_balance]).to include("must be greater than or equal to 0")
    end

    it 'allows points_balance to be zero' do
      subject.points_balance = 0
      expect(subject).to be_valid
    end

    it 'allows points_balance to be positive' do
      subject.points_balance = 1000
      expect(subject).to be_valid
    end
  end

  describe 'associations' do
    it 'has many redemptions' do
      association = described_class.reflect_on_association(:redemptions)
      expect(association.macro).to eq :has_many
    end

    it 'destroys associated redemptions when destroyed' do
      user = create(:user)
      create_list(:redemption, 3, user: user)
      expect { user.destroy }.to change { Redemption.count }.by(-3)
    end
  end

  describe 'default values' do
    it 'sets default points_balance to 0 if not provided' do
      user = User.new(email: 'test@example.com', name: 'Test User')
      expect(user.points_balance).to eq(0)
    end
  end
end
