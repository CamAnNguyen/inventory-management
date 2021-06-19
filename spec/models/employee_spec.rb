require 'rails_helper'

RSpec.describe Employee do
  it 'able to create WarehouseEmployee' do
    warehouse_employee = create(:warehouse_employee)
    expect(warehouse_employee.role).to eq('WarehouseEmployee')

    employee = Employee.create!(
      name: 'Employee',
      access_code: '12345',
      role: 'WarehouseEmployee'
    )
    latest_warehouse_employee = WarehouseEmployee.last
    expect(latest_warehouse_employee.id).to eq(employee.id)
  end

  it 'able to create CustomerServiceEmployee' do
    customer_service_employee = create(:customer_service_employee)
    expect(customer_service_employee.role).to eq('CustomerServiceEmployee')

    employee = Employee.create!(
      name: 'Employee',
      access_code: '12345',
      role: 'CustomerServiceEmployee'
    )
    latest_customer_service_employee = CustomerServiceEmployee.last
    expect(latest_customer_service_employee.id).to eq(employee.id)
  end
end
