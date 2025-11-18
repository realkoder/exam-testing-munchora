class SubscriptionPlan < ApplicationRecord
  has_many :subscriptions

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :billing_cycle, presence: true, inclusion: { in: %w[monthly yearly] }
  validates :feature_description, presence: true
end
