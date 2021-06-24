require 'rails_helper'

RSpec.describe FindReturnedOrder do
  let(:employee) { create(:warehouse_employee) }
  let(:product) { create(:product) }
  let(:second_product) { create(:product) }

  let(:order) do
    create(
      :order,
      line_items: [
        build(:order_line_item, product: product, quantity: 2),
        build(:order_line_item, product: second_product, quantity: 5)
      ]
    )
  end

  let(:second_order) do
    create(
      :order,
      line_items: [
        build(:order_line_item, product: product, quantity: 5),
        build(:order_line_item, product: second_product, quantity: 7)
      ]
    )
  end

  before do
    ReceiveProduct.run(employee, product, 10)
    ReceiveProduct.run(employee, second_product, 20)

    FindFulfillableOrder.fulfill_order(employee, order.id)
    FindFulfillableOrder.fulfill_order(employee, second_order.id)

    FindFulfilledOrder.mark_order_returned(employee, order.id)
    FindFulfilledOrder.mark_order_returned(employee, second_order.id)

    product.reload
    second_product.reload
  end

  it 'returns nil if processed by customer service employee' do
    cs_employee = create(:customer_service_employee)
    expect(FindReturnedOrder.restock_order(cs_employee, order.id)).to be_nil
  end

  it 'returns the correct returned order' do
    expect(product.on_shelf).to eq(3)
    expect(second_product.on_shelf).to eq(8)

    FindReturnedOrder.restock_order(employee, order.id)
    product.reload
    second_product.reload

    expect(product.on_shelf).to eq(5)
    expect(second_product.on_shelf).to eq(13)

    FindReturnedOrder.restock_order(employee, second_order.id)
    product.reload
    second_product.reload

    expect(product.on_shelf).to eq(10)
    expect(second_product.on_shelf).to eq(20)
  end
end
