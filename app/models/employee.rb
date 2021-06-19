class Employee < ApplicationRecord
  validates :name, presence: true
  validates :access_code, uniqueness: true

  self.inheritance_column = 'role'
end
