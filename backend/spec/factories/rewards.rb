FactoryBot.define do
  factory :reward do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence(word_count: 10) }
    cost { 500 }
    image_url { Faker::LoremFlickr.image(size: "300x300", search_terms: ['gift']) }
    category { %w[Gift\ Card Merchandise Perk].sample }
    stock_quantity { 10 }
    active { true }

    trait :gift_card do
      category { 'Gift Card' }
      cost { 1000 }
    end

    trait :merchandise do
      category { 'Merchandise' }
      cost { 750 }
    end

    trait :perk do
      category { 'Perk' }
      cost { 250 }
    end

    trait :out_of_stock do
      stock_quantity { 0 }
    end

    trait :unlimited_stock do
      stock_quantity { nil }
    end

    trait :inactive do
      active { false }
    end

    trait :expensive do
      cost { 5000 }
    end
  end
end
