class AddOrderIdToInventories < ActiveRecord::Migration[6.0]
  def change
    add_reference :inventories, :order, foreign_key: true, null: true
  end
end
