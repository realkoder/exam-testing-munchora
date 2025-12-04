FactoryBot.define do
  factory :llm_usage do
    association :user
    association :recipe
    provider { "openai" }
    model { 'gpt-4.1-mini' }
    prompt { "Test prompt" }
    prompt_tokens { 60 }
    completion_tokens { 500 }
  end
end
