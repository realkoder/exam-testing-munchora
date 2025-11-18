class LlmUsage < ApplicationRecord
  self.primary_key = 'id'

  before_create -> { self.id ||= SecureRandom.uuid }

  belongs_to :user, optional: true
  belongs_to :recipe, optional: true

  validates :model, presence: true
  validates :provider, presence: true
  validates :prompt, presence: true
  validates :prompt_tokens, :completion_tokens,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
