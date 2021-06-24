require 'rails_helper'

RSpec.describe FixAddress do
  let(:cs_employee) { create(:customer_service_employee) }
  let(:whs_employee) { create(:warehouse_employee) }
  let(:address) { create(:address) }
  let(:new_address) do
    {
      street_1: '321 New Street',
      street_2: '2nd street',
      city: 'San Francisco',
      state: 'CA',
      zip: '10002'
    }
  end

  let(:product) { create(:product) }
  let(:second_product) { create(:product) }

  let(:order) do
    create(
      :order,
      ships_to: address,
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
    ReceiveProduct.run(whs_employee, product, 10)
    ReceiveProduct.run(whs_employee, second_product, 20)

    FindFulfillableOrder.fulfill_order(whs_employee, order.id)
    FindFulfillableOrder.fulfill_order(whs_employee, second_order.id)

    FindFulfilledOrder.mark_order_returned(whs_employee, order.id)

    product.reload
    second_product.reload
  end

  it 'returns nil if processed by warehouse employee' do
    res = FindReturnedOrder.fix_address(whs_employee, address.id, new_address)
    expect(res).to be_nil
  end

  it 'return nil if address is already fixed' do
    another_address = {
      street_1: '666 Street',
      street_2: 'Another street',
      city: 'Austin',
      state: 'TX',
      zip: '10003'
    }

    expect(address.fixed).to eq(false)

    FindReturnedOrder.fix_address(cs_employee, address.id, new_address)
    res = FindReturnedOrder.fix_address(cs_employee, address.id, another_address)
    expect(res).to be_nil

    address.reload
    expect(address.fixed).to eq(true)
    expect(address.street_1).to eq(new_address[:street_1])
    expect(address.street_2).to eq(new_address[:street_2])
    expect(address.city).to eq(new_address[:city])
    expect(address.state).to eq(new_address[:state])
    expect(address.zip).to eq(new_address[:zip])
  end

  it 'only fix address of returned order' do
    second_address = second_order.ships_to
    expect(second_address.fixed).to eq(false)

    res = FindReturnedOrder.fix_address(cs_employee, second_address, new_address)
    expect(res).to be_nil
    expect(second_address.fixed).to eq(false)
  end

  it 'return the updated address after fixing' do
    expect(address.fixed).to eq(false)

    FindReturnedOrder.fix_address(cs_employee, address.id, new_address)
    address.reload

    expect(address.fixed).to eq(true)
    expect(address.street_1).to eq(new_address[:street_1])
    expect(address.street_2).to eq(new_address[:street_2])
    expect(address.city).to eq(new_address[:city])
    expect(address.state).to eq(new_address[:state])
    expect(address.zip).to eq(new_address[:zip])
  end

end
