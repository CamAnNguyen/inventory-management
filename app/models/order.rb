class Order < ApplicationRecord
  belongs_to :ships_to, class_name: 'Address'
  has_many :line_items, class_name: 'OrderLineItem'
  has_many :inventories

  scope :recent, -> { order(created_at: :desc) }
  scope :not_fulfilled, -> { left_joins(:inventories).where(inventories: { order_id: nil }) }
  scope :fulfilled, lambda {
    joins(:inventories)
      .group('orders.id')
      .where(inventories: { status: InventoryStatusChange::STATUSES[:shipped] })
  }
  scope :returned, lambda {
    joins(:inventories)
      .group('orders.id')
      .where(inventories: { status: InventoryStatusChange::STATUSES[:returned] })
  }

  scope :fulfillable, lambda {
    not_fulfilled
      .joins(:line_items)
      .joins(<<~SQL)
        LEFT OUTER JOIN products
          ON order_line_items.product_id = products.id
         AND order_line_items.quantity <= products.on_shelf
      SQL
      .group(:id)
      .having(<<~SQL)
        COUNT(DISTINCT products.id) =
        COUNT(DISTINCT order_line_items.product_id)
      SQL
      .order(:created_at, :id)
  }

  def cost
    line_items.inject(Money.zero) do |acc, li|
      acc + li.cost
    end
  end

  def fulfilled?
    inventory_size = inventories.count

    (
      !inventory_size.zero? &&
      inventories
        .where(status: InventoryStatusChange::STATUSES[:shipped])
        .count == inventory_size
    )
  end

  def returned?
    inventory_size = inventories.count

    (
      !inventory_size.zero? &&
      inventories
        .where(status: InventoryStatusChange::STATUSES[:returned])
        .count == inventory_size
    )
  end

  # This method should include one more condition: not_fulfilled (`!fulfilled?`)
  # Potential bug:
  #   If this method is used for individual order fulfillable checking
  #   it might cause additional inventories created
  #
  # In addition, seems this method is having N+1 queries problem?
  def fulfillable?
    line_items.all?(&:fulfillable?)
  end
end
