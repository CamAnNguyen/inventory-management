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
      ReceiveProduct.run(employee, line_item.product, line_item.quantity)
    end
  end
  private_class_method :restock

  def self.fix_address(employee, address_id, new_address)
    return nil if Order.returned.where(ships_to_id: address_id).empty? ||
                  !employee.instance_of?(CustomerServiceEmployee)

    address = Address.find(address_id)
    return nil if address.nil?

    FixAddress.run(employee, address, new_address)
  end
end
