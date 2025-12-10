FactoryBot.define do
  factory :delivery do
    association :order
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    phone { Faker::PhoneNumber.cell_phone }
    delivery_method { "by courier" }
    payment_method { "cash" }
    delivery_status { "pending" }
    delivery_notes { Faker::Lorem.sentence(word_count: 5)[0..49] }
    delivery_time { Faker::Time.forward(days: 2, period: :day) }
    delivered_at { nil }

    trait :pickup do
      delivery_method { "pickup" }
      address { nil }
      city { nil }
      pickup_time { Faker::Time.forward(days: 1, period: :day) }
    end

    trait :by_courier do
      delivery_method { "by courier" }
      delivery_time { Faker::Time.forward(days: 3, period: :day) }
    end

    trait :cash_payment do
      payment_method { "cash" }
    end

    trait :card_payment do
      payment_method { "card" }
    end

    trait :online_payment do
      payment_method { "online" }
    end

    trait :pending do
      delivery_status { "pending" }
      delivered_at { nil }
    end

    trait :in_transit do
      delivery_status { "in_transit" }
      delivered_at { nil }
    end

    trait :delivered do
      delivery_status { "delivered" }
      delivered_at { Faker::Time.backward(days: 1, period: :day) }
    end

    trait :with_notes do
      delivery_notes { Faker::Lorem.characters(number: 45) }
    end

    trait :invalid do
      address { nil }
      city { nil }
      phone { "invalid" }
    end
  end
end
