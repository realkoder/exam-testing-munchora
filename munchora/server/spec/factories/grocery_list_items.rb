FactoryBot.define do
  factory :grocery_list_item do
    association :grocery_list
    name { 'Item' }
    category { 'fish 🐟' }
  end
end
