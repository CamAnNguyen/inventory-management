require 'rails_helper'

RSpec.describe FindFulfilledOrder do
  let(:employee) { create(:warehouse_employee) }
  let(:product) { create(:product) }
  let(:order) do
    create(
      :order,
      line_items: [build(:order_line_item, product: product, quantity: 2)]
    )
  end

  let(:second_order) do
    create(
      :order,
      line_items: [build(:order_line_item, product: product, quantity: 2)]
    )
  end

  before do
    ReceiveProduct.run(employee, product, 5)
    FindFulfillableOrder.fulfill_order(employee, order.id)
    FindFulfillableOrder.fulfill_order(employee, second_order.id)
  end

  it 'returns nil if processed by customer service employee' do
    cs_employee = create(:customer_service_employee)
    expect(FindFulfilledOrder.mark_order_returned(cs_employee, order.id)).to be_nil
    expect(Order.returned.length).to eq(0)
  end

  it 'returns the correct fulfilled order' do
    FindFulfilledOrder.mark_order_returned(employee, order.id)
    expect(order.inventories.count).to eq(2)
    expect(Order.returned).to match_array([order])

    FindFulfilledOrder.mark_order_returned(employee, second_order.id)
    expect(order.inventories.count).to eq(2)
    expect(second_order.inventories.count).to eq(2)
    expect(Order.returned).to match_array([order, second_order])
  end
end
