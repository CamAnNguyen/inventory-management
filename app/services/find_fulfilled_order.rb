class FindFulfilledOrder
  def self.mark_order_returned(employee, order_id)
    mark_returned(employee, Order.fulfilled.find(order_id))
  end

  def self.mark_returned(employee, order)
    return unless order && employee.instance_of?(WarehouseEmployee)

    order.line_items.each do |line_item|
      inventory_items = Inventory.shipped.where(
        product: line_item.product,
        order: order
      ).limit(line_item.quantity)
      MarkInventoryReturned.run(employee, inventory_items, order)
    end
  end
  private_class_method :mark_returned
end
