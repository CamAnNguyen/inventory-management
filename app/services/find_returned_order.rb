class FindReturnedOrder
  def self.restock_order(employee, order_id)
    restock(employee, Order.returned.find(order_id))
  end

  def self.restock(employee, order)
    return nil unless order && employee.instance_of?(WarehouseEmployee)

    order.line_items.each do |line_item|
      inventory_items = Inventory.returned.where(
        product: line_item.product,
        order: order
      ).limit(line_item.quantity)
      RestockInventory.run(employee, inventory_items, order)
    end
  end
  private_class_method :restock
end
