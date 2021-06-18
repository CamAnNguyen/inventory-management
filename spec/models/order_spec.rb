require 'rails_helper'

RSpec.describe Order do
  let(:product) { create(:product) }
  let(:second_product) { create(:product) }
  let(:address) { create(:address) }
  let(:order) do
    create(
      :order,
      line_items: [
        build(:order_line_item, product: product, quantity: 2),
        build(:order_line_item, product: second_product, quantity: 3)
      ]
    )
  end
  let(:second_order) do
    create(
      :order,
      line_items: [
        build(:order_line_item, product: product, quantity: 2),
        build(:order_line_item, product: second_product, quantity: 20)
      ]
    )
  end

  let(:employee) { create(:employee) }
  let(:quantity) { 10 }

  before do
    ReceiveProduct.run(employee, product, quantity)
    ReceiveProduct.run(employee, second_product, quantity)

    product.reload
    second_product.reload
  end

  describe '.fulfillable' do
    it 'includes fulfillable order only' do
      fulfillable_order = Order.create!(ships_to: address)
      OrderLineItem.create!(order: fulfillable_order, product: product, quantity: 2)
      OrderLineItem.create!(order: fulfillable_order, product: second_product, quantity: 2)

      unfulfillable_order = Order.create!(ships_to: address)
      OrderLineItem.create!(order: unfulfillable_order, product: product, quantity: 2)
      OrderLineItem.create!(order: unfulfillable_order, product: second_product, quantity: 20)

      expect(Order.fulfillable).not_to include(unfulfillable_order)
      expect(Order.fulfillable).to include(fulfillable_order)
    end
  end

  describe '#cost' do
    it 'returns correct cost' do
      expect(order.cost).to eq(product.price * 5)
    end
  end

  describe '#fulfillable?' do
    it 'returns true if fulfillable' do
      expect(order.fulfillable?).to eq(true)
    end

    it 'returns false if is not fulfillable' do
      expect(second_order.fulfillable?).to eq(false)
    end
  end

  describe '#fulfilled?' do
    it 'returns false if is not fulfilled' do
      expect(order.fulfilled?).to eq(false)
    end

    it 'returns true if is fulfilled' do
      fulfillable_order = Order.create!(ships_to: address)
      OrderLineItem.create!(order: fulfillable_order, product: product, quantity: 2)
      OrderLineItem.create!(order: fulfillable_order, product: second_product, quantity: 2)
      FindFulfillableOrder.fulfill_order(employee, fulfillable_order.id)

      expect(fulfillable_order.fulfilled?).to eq(true)
    end
  end
end
