class FixesController < ApplicationController
  before_action :require_customer_service_employee

  def create
    FindReturnedOrder.fix_address(current_user, params[:address_id], address_params)

    redirect_to employees_path
  end

  private

  def address_params
    params.require(:address).permit(:street_1, :street_2, :city, :state, :zip)
  end
end
