class ReturnsController < ApplicationController
  before_action :require_warehouse_employee

  def create
    FindFulfilledOrder.mark_order_returned(current_user, params[:order_id])

    redirect_to employees_path
  end
end
