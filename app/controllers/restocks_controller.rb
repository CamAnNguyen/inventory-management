class RestocksController < ApplicationController
  before_action :require_warehouse_employee

  def create
    FindReturnedOrder.restock_order(current_user, params[:order_id])

    redirect_to employees_path
  end
end
