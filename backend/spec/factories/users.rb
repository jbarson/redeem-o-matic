FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    points_balance { 1000 }

    trait :with_low_balance do
      points_balance { 100 }
    end

    trait :with_high_balance do
      points_balance { 5000 }
    end

    trait :with_zero_balance do
      points_balance { 0 }
    end
  end
end
