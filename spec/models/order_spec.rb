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
      expect(Order.fulfillable).not_to include(second_order)
      expect(Order.fulfillable).to include(order)
    end
  end

  describe '.fulfilled' do
    it 'includes fulfilled order only' do
      expect(Order.fulfilled).not_to include(order)

      FindFulfillableOrder.fulfill_order(employee, order.id)

      expect(Order.fulfilled).to include(order)
    end
  end

  describe '.returned' do
    it 'includes returned order only' do
      expect(Order.returned).not_to include(order)

      FindFulfillableOrder.fulfill_order(employee, order.id)
      FindFulfilledOrder.mark_order_returned(employee, order.id)

      expect(Order.returned).to include(order)
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
      expect(order.fulfilled?).to eq(false)
      FindFulfillableOrder.fulfill_order(employee, order.id)
      expect(order.fulfilled?).to eq(true)
    end
  end

  describe '#returned?' do
    before do
      FindFulfillableOrder.fulfill_order(employee, order.id)
    end

    it 'returns false if is not mark as returned' do
      expect(order.returned?).to eq(false)
    end

    it 'returns true if its inventories is mark as returned' do
      cs_employee = create(:customer_service_employee)
      line_items = FindFulfilledOrder.mark_order_returned(cs_employee, order.id)
      expect(line_items.nil?).to eq(true)

      expect(order.returned?).to eq(false)
      FindFulfilledOrder.mark_order_returned(employee, order.id)
      expect(order.returned?).to eq(true)
    end
  end
end
