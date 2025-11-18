class RecipeSummaryView < ApplicationRecord
  self.table_name = 'recipe_summary_view' # points the model to the view

  # Views are read-only
  def readonly?
    true
  end
end
