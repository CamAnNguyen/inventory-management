class Address < ApplicationRecord
  has_many :orders, class_name: 'Order', foreign_key: :ships_to_id

  validates :recipient, :street_1, :city, :state, :zip, presence: true

  def fixed
    self[:fixed] || false
  end
end
