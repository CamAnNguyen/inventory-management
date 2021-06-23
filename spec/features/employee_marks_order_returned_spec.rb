require 'rails_helper'

RSpec.feature 'Employee mark order returned' do
  scenario 'unsuccessfully for customer service employee' do
    product = create(:product)
    employee = create(:customer_service_employee, name: 'Jane Doe', access_code: '41315')

    ReceiveProduct.run(employee, product, 10)
    order = create(:order)
    create(:order_line_item, order: order, product: product, quantity: 5)

    visit root_path
    click_on sign_in
    attempt_code('41315')

    expect(page).to have_fulfillable_order(order)
    view_order(order)
    fulfill_order
    expect(page).to have_fulfilled_order(order)

    view_order(order)
    expect(page).not_to allow_fulfillment
    expect(page).not_to allow_mark_returned
  end

  scenario 'successfully' do
    product = create(:product)
    employee = create(:employee, name: 'Jane Doe', access_code: '41315')

    ReceiveProduct.run(employee, product, 10)
    order = create(:order)
    create(:order_line_item, order: order, product: product, quantity: 5)

    visit root_path
    click_on sign_in
    attempt_code('41315')

    expect(page).to have_fulfillable_order(order)
    view_order(order)
    fulfill_order
    expect(page).to have_fulfilled_order(order)

    view_order(order)
    expect(page).not_to allow_fulfillment
    expect(page).to allow_mark_returned

    mark_order_returned
    expect(page).to have_returned_order(order)
  end
end
