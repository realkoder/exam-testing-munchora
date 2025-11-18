class CreateFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.string :message
      t.string :name
      t.string :email
      t.string :category

      t.timestamps
    end
  end
end
