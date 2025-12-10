FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "user#{n}@example.com" }
    phone { Faker::PhoneNumber.cell_phone }
    password { "SecurePass123!" }
    password_confirmation { "SecurePass123!" }
    role { "customer" }

    trait :admin do
      role { "admin" }
    end

    trait :staff do
      role { "staff" }
    end

    trait :with_orders do
      transient do
        orders_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:order, evaluator.orders_count, user: user)
      end
    end

    trait :with_cart_items do
      transient do
        cart_items_count { 2 }
      end

      after(:create) do |user, evaluator|
        create_list(:cart_item, evaluator.cart_items_count, user: user)
      end
    end

    trait :oauth_google do
      provider { "google" }
      uid { Faker::Number.number(digits: 21).to_s }
      oauth_token { SecureRandom.hex(32) }
      oauth_expires_at { 1.hour.from_now }
      password { SecureRandom.hex(32) }
      password_confirmation { password }
    end

    trait :invalid do
      email { "invalid_email" }
    end
  end
end
