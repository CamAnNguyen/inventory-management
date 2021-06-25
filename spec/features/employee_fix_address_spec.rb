require 'rails_helper'

RSpec.feature 'Employee fix address' do
  before do
    whs_employee = create(:employee, name: 'John Doe', access_code: '41315')
    create(:customer_service_employee, name: 'Jane Doe', access_code: '12345')

    product = create(:product)
    order = create(:order)
    create(:order_line_item, order: order, product: product, quantity: 5)

    ReceiveProduct.run(whs_employee, product, 10)

    visit root_path
    click_on sign_in
    attempt_code('41315')
    view_order(order)
    fulfill_order
    view_order(order)
    mark_order_returned

    click_on sign_out
  end

  scenario 'unsuccessfully for warehouse employee' do
    visit root_path
    click_on sign_in
    attempt_code('41315')

    order = Order.first
    expect(page).to have_returned_order(order)
    expect(page).not_to have_issued_address(order.ships_to)
  end

  scenario 'successfully for customer service employee' do
    visit root_path
    click_on sign_in
    attempt_code('12345')

    order = Order.first
    address = order.ships_to
    expect(page).to have_issued_address(address)
    view_address(address)

    expect(address.fixed).to eq(false)
    expect(page).to allow_fix_address

    new_address = {
      street_1: '666 Street',
      street_2: 'Another street',
      city: 'Austin',
      state: 'TX',
      zip: '10003'
    }
    fix_address(new_address)
    address.reload

    expect(address.street_1).to eq(new_address[:street_1])
    expect(address.street_2).to eq(new_address[:street_2])
    expect(address.city).to eq(new_address[:city])
    expect(address.state).to eq(new_address[:state])
    expect(address.zip).to eq(new_address[:zip])
    expect(address.fixed).to eq(true)

    expect(page).not_to have_issued_address(address)
  end
end
