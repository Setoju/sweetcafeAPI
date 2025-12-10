FactoryBot.define do
  factory :menu_item do
    association :category
    sequence(:name) { |n| "Menu Item #{n}" }
    description { Faker::Food.description }
    price { Faker::Commerce.price(range: 5.0..50.0) }
    size { Faker::Number.between(from: 200, to: 500).to_s }
    available { true }
    available_quantity { Faker::Number.between(from: 10, to: 100) }
    image_url { Faker::LoremFlickr.image(size: "300x300", search_terms: [ 'food' ]) }

    trait :unavailable do
      available { false }
      available_quantity { 0 }
    end

    trait :low_stock do
      available_quantity { Faker::Number.between(from: 1, to: 5) }
    end

    trait :out_of_stock do
      available_quantity { 0 }
      available { false }
    end

    trait :expensive do
      price { Faker::Commerce.price(range: 100.0..500.0) }
    end

    trait :cheap do
      price { Faker::Commerce.price(range: 1.0..10.0) }
    end

    trait :with_order_items do
      transient do
        order_items_count { 2 }
      end

      after(:create) do |menu_item, evaluator|
        create_list(:order_item, evaluator.order_items_count, menu_item: menu_item)
      end
    end

    trait :with_cart_items do
      transient do
        cart_items_count { 2 }
      end

      after(:create) do |menu_item, evaluator|
        create_list(:cart_item, evaluator.cart_items_count, menu_item: menu_item)
      end
    end

    trait :invalid do
      name { "" }
      price { -10 }
    end
  end
end
