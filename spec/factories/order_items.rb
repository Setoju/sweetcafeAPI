FactoryBot.define do
  factory :order_item do
    association :order
    association :menu_item
    total_quantity { Faker::Number.between(from: 1, to: 5) }
    price { menu_item&.price || Faker::Commerce.price(range: 5.0..50.0) }
    subtotal { nil }

    after(:build) do |order_item|
      order_item.price ||= order_item.menu_item.price if order_item.menu_item
      order_item.subtotal = order_item.price * order_item.total_quantity if order_item.price && order_item.total_quantity
    end

    trait :large_quantity do
      total_quantity { Faker::Number.between(from: 10, to: 20) }
    end

    trait :single_item do
      total_quantity { 1 }
    end

    trait :without_menu_item do
      menu_item { nil }
    end

    trait :invalid do
      total_quantity { 0 }
      price { -10 }
    end
  end
end
