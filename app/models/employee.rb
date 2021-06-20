require 'sti_preload'

class Employee < ApplicationRecord
  include StiPreload

  validates :name, presence: true
  validates :access_code, uniqueness: true

  self.inheritance_column = 'role'
end
