class FixAddress
  def self.run(employee, address, new_address)
    new(employee: employee, address: address, new_address: new_address).run
  end

  def initialize(employee:, address:, new_address:)
    @employee = employee
    @address = address
    @new_address = new_address
  end

  def run
    return nil if address.fixed || !employee.instance_of?(CustomerServiceEmployee)

    address.update!(
      street_1: @new_address[:street_1],
      street_2: @new_address[:street_2],
      city: @new_address[:city],
      state: @new_address[:state],
      zip: @new_address[:zip],
      fixed: true
    )
  end

  private

  attr_reader :employee, :address, :new_address
end
