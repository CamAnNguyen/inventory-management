class MarkInventoryReturned
  def self.run(employee, inventory_items, order)
    new(employee: employee, inventory_items: inventory_items, order: order).run
  end

  def initialize(employee:, inventory_items:, order:)
    @employee = employee
    @inventory_items = inventory_items
    @order = order
  end

  def run
    Inventory.transaction do
      inventory_items.each do |inventory|
        mark_inventory_returned(inventory)
      end
    end
  end

  private

  attr_reader :employee, :inventory_items, :order

  def mark_inventory_returned(inventory)
    inventory.with_lock do
      InventoryStatusChange.create!(
        inventory: inventory,
        status_from: inventory.status,
        status_to: :returned,
        actor: employee
      )
      inventory.update!(status: :returned, order: order)
    end
  end
end
