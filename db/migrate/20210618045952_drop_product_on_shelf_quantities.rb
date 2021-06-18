class DropProductOnShelfQuantities < ActiveRecord::Migration[6.0]
  def up
    drop_view :product_on_shelf_quantities
  end

  def down
    create_view :product_on_shelf_quantities, version: 2
  end
end
