require 'rails_helper'

RSpec.describe OrderLineItem do
  let(:product) { create(:product) }
  let(:order_line_item) do
    create(:order_line_item, product: product, quantity: 2)
  end
  let(:employee) { create(:employee) }
  let(:quantity) { 10 }

  before do
    ReceiveProduct.run(employee, product, quantity)
    product.reload
  end

  describe '#on_shelf_quantity' do
    it 'returns correct quantity of product on shelf' do
      expect(order_line_item.on_shelf_quantity).to eq(quantity)
    end
  end

  describe '#cost' do
    it 'returns correct cost' do
      expect(order_line_item.cost).to eq(order_line_item.quantity * product.price)
    end
  end

  describe '#fulfillable?' do
    it 'returns true if fulfillable' do
      expect(order_line_item.fulfillable?).to eq(true)
    end

    it 'returns false if is not fulfillable' do
      second_order_line_item = create(
        :order_line_item,
        product: product,
        quantity: quantity + 1
      )

      expect(second_order_line_item.fulfillable?).to eq(false)
    end
  end
end
