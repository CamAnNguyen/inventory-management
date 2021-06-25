module AddressesHelper
  def have_issued_address(address)
    have_css("[data-id=address-#{address.id}]", text: address.recipient)
  end

  def view_address(address)
    find("[data-id=address-#{address.id}] a", match: :first).click
  end

  def allow_fix_address
    have_css('input[type="submit"][value="Fix Address"]')
  end

  def fix_address(new_address)
    fill_in 'inline-street_1', with: new_address[:street_1]
    fill_in 'inline-street_2', with: new_address[:street_2]
    fill_in 'inline-city', with: new_address[:city]
    fill_in 'inline-state', with: new_address[:state]
    fill_in 'inline-zip', with: new_address[:zip]

    click_on(t('addresses.show.fix_address'))
  end
end

RSpec.configure do |config|
  config.include AddressesHelper, type: :feature
end
