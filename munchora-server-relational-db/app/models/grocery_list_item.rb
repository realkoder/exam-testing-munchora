class GroceryListItem < ApplicationRecord
  belongs_to :grocery_list
  belongs_to :added_by, class_name: 'User', optional: true

  validates :name, presence: true, length: { maximum: 50 }
  validates :category, presence: true, inclusion: { in: GroceryCategories::CATEGORIES }
end
