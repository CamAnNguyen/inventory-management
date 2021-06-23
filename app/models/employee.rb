require 'sti_preload'

class Employee < ApplicationRecord
  include StiPreload

  validates :name, presence: true
  validates :access_code, uniqueness: true

  self.inheritance_column = 'role'

  def warehouse_employee?
    instance_of? WarehouseEmployee
  end

  def customer_service_employee?
    instance_of? CustomerServiceEmployee
  end
end
