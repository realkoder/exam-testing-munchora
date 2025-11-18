class GroceryList < ApplicationRecord
  self.primary_key = 'id'

  before_create -> { self.id ||= SecureRandom.uuid }

  belongs_to :owner, class_name: 'User'

  has_many :items, class_name: 'GroceryListItem', dependent: :destroy
  has_many :grocery_list_shares, dependent: :destroy
  has_many :shared_users, through: :grocery_list_shares, source: :user

  validates :name, presence: true, length: { maximum: 50 }
end
