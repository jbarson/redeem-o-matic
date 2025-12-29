FactoryBot.define do
  factory :redemption do
    association :user
    association :reward
    points_spent { reward.cost }
    status { 'completed' }

    trait :pending do
      status { 'pending' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end
  end
end
