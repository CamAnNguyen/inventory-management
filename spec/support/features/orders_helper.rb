module OrdersHelper
  def have_fulfillable_order(order)
    have_css("[data-id=order-#{order.id}]", text: 'Fulfillable')
  end

  def have_unfulfillable_order(order)
    have_css("[data-id=order-#{order.id}]", text: 'Unfulfillable')
  end

  def have_fulfilled_order(order)
    have_css("[data-id=order-#{order.id}]", text: 'Fulfilled')
  end

  def have_returned_order(order)
    have_css("[data-id=order-#{order.id}]", text: 'Fulfilled')
  end

  def view_order(order)
    find("[data-id=order-#{order.id}] a", match: :first).click
  end

  def fulfill_order
    click_on(t('orders.show.fulfill_order'))
  end

  def allow_fulfillment
    have_css('button:not(:disabled)', text: 'Fulfill order')
  end

  def allow_mark_returned
    have_css('button:not(:disabled)', text: 'Mark order returned')
  end

  def mark_order_returned
    click_on(t('orders.show.mark_order_returned'))
  end
end

RSpec.configure do |config|
  config.include OrdersHelper, type: :feature
end
