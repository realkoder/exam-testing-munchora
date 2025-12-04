class GroceryLists::Creator
  def self.call(user, params)
    user.grocery_lists.create!(params)
  end
end
