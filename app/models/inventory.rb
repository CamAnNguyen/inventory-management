class Inventory < ApplicationRecord
  enum status: InventoryStatusChange::STATUSES

  belongs_to :product
  counter_culture :product,
                  column_name: proc { |i|
                    i.on_shelf? ? InventoryStatusChange::STATUSES[:on_shelf] : nil
                  },
                  column_names: {
                    [
                      'inventories.status = ?',
                      InventoryStatusChange::STATUSES[:on_shelf]
                    ] => 'on_shelf'
                  }

  belongs_to :order, required: false

  validates :product, presence: true

  def on_shelf?
    status == InventoryStatusChange::STATUSES[:on_shelf]
  end
end
