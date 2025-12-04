FactoryBot.define do
  factory :recipe_comment do
    user { nil }
    recipe { nil }
    comment { "MyText" }
  end
end
