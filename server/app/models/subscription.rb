class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_plan
  has_many :invoices

  validates :status, presence: true, inclusion: { in: %w[active cancelled past_due] }
end
