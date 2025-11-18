class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :subscription

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :status, presence: true, inclusion: { in: %w[draft paid failed refunded] }
  validate :paid_at_if_paid
  validates :period_start, presence: true
  validates :period_end, presence: true
  validate :end_after_start

  private

  # Ensure paid_at is set if status is 'paid'
  def paid_at_if_paid
    if status == 'paid' && paid_at.blank?
      errors.add(:paid_at, 'must be set if invoice is paid')
    end
  end

  # Custom validation to ensure period_end is after start
  def end_after_start
    return if period_start.blank? || period_end.blank?

    if period_end <= period_start
      errors.add(:period_end, 'must be after period_start')
    end
  end
end
