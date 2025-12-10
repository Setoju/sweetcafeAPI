FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    description { Faker::Food.description }

    trait :with_menu_items do
      transient do
        menu_items_count { 5 }
      end

      after(:create) do |category, evaluator|
        create_list(:menu_item, evaluator.menu_items_count, category: category)
      end
    end

    trait :beverages do
      name { "Beverages" }
      description { "Hot and cold drinks" }
    end

    trait :desserts do
      name { "Desserts" }
      description { "Sweet treats and pastries" }
    end

    trait :main_courses do
      name { "Main Courses" }
      description { "Hearty meals and entrees" }
    end

    trait :invalid do
      name { "" }
    end
  end
end
