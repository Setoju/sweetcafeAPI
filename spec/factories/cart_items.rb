FactoryBot.define do
  factory :cart_item do
    association :user
    association :menu_item
    total_quantity { Faker::Number.between(from: 1, to: 10) }

    trait :large_quantity do
      total_quantity { Faker::Number.between(from: 5, to: 15) }
    end

    trait :single_item do
      total_quantity { 1 }
    end

    trait :with_unavailable_item do
      association :menu_item, factory: [ :menu_item, :unavailable ]
    end

    trait :exceeding_stock do
      transient do
        stock_quantity { 5 }
      end

      after(:build) do |cart_item, evaluator|
        cart_item.menu_item.update(available_quantity: evaluator.stock_quantity)
        cart_item.total_quantity = evaluator.stock_quantity + 10
      end
    end

    trait :invalid do
      total_quantity { 0 }
    end
  end
end
