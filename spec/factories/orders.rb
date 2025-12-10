FactoryBot.define do
  factory :order do
    association :user
    status { "pending" }
    total_amount { nil }
    notes { Faker::Lorem.sentence }

    trait :with_items do
      transient do
        items_count { 3 }
      end

      after(:create) do |order, evaluator|
        create_list(:order_item, evaluator.items_count, order: order)
        order.update(total_amount: order.order_items.sum(&:subtotal))
      end
    end

    trait :with_delivery do
      after(:create) do |order|
        create(:delivery, order: order)
      end
    end

    trait :pending do
      status { "pending" }
    end

    trait :completed do
      status { "completed" }
    end

    trait :delivered do
      status { "delivered" }
    end

    trait :cancelled do
      status { "cancelled" }
    end

    trait :with_calculated_total do
      after(:create) do |order|
        order.update(total_amount: order.order_items.sum(&:subtotal)) if order.order_items.any?
      end
    end

    trait :invalid do
      status { "invalid_status" }
    end
  end
end
