class AddressesController < ApplicationController
  before_action :require_signin

  def show
    @address = Address.find(params[:id])
    @fixable = !(
      @address.fixed ||
      Order.returned.where(ships_to_id: params[:id]).empty?
    )
  end
end
