class EmployeesController < ApplicationController
  before_action :require_signin

  def index
    @fulfillable_orders = Order.fulfillable.limit(10)
    @recent_orders = Order.recent.limit(10)
    @products = Product.order(id: :asc).all
    @fulfilled_orders = Order.fulfilled.limit(10)
    @returned_orders = Order.returned.limit(10)
    @addresses = Address
                 .joins(:orders)
                 .where('orders.ships_to_id = addresses.id')
                 .where(orders: Order.returned, fixed: [nil, false])
                 .distinct
  end
end
