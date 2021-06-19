require 'rails_helper'

RSpec.describe FindFulfillableOrder do
  it 'returns the oldest fulfillable order available' do
    employee = create(:employee)
    product = create(:product)

    ReceiveProduct.run(employee, product, 5)
    order = create(:order, line_items: [build(:order_line_item, product: product, quantity: 2)])
    second_order = create(:order, line_items: [build(:order_line_item, product: product, quantity: 2)])

    expect(Order.fulfilled).to be_empty

    FindFulfillableOrder.begin_fulfillment(employee)

    expect(Order.fulfilled).to match_array([order])

    FindFulfillableOrder.begin_fulfillment(employee)

    expect(Order.fulfilled).to match_array([order, second_order])

    expect(FindFulfillableOrder.begin_fulfillment(employee)).to be_nil
  end

  it 'fulfills properly parallely' do
    num_threads = 4
    quantity = 3

    employees = []
    orders = []
    product = create(:product)

    num_threads.times do
      employee = create(:employee)
      employees.push(employee)

      order = create(
        :order,
        line_items: [build(:order_line_item, product: product, quantity: 1)]
      )
      orders.push(order)
    end

    quantity.times do |i|
      ReceiveProduct.run(employees[i], product, 1)
    end

    product.reload
    expect(product.on_shelf).to eq(quantity)

    num_threads.times.map do |i|
      Thread.new do
        FindFulfillableOrder.fulfill_order(employees[i], orders[i].id)
      end
    end.each(&:join)

    # Even with 4 threads, only 3 inventories are created
    expect(Inventory.count).to eq(quantity)
  end
end
