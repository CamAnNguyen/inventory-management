class ApplicationController < ActionController::Base
  def current_user
    if session[:employee_id]
      Employee.find_by(id: session[:employee_id])
    end
  end

  helper_method :current_user

  def signed_in?
    current_user.present?
  end

  helper_method :signed_in?

  def require_signin
    if signed_out?
      redirect_to sign_in_path
    end
  end

  def require_warehouse_employee
    require_signin

    unless current_user.warehouse_employee?
      redirect_to employees_path
    end
  end

  def require_customer_service_employee
    require_signin

    unless current_user.customer_service_employee?
      redirect_to employees_path
    end
  end

  def warehouse_employee?
    current_user.warehouse_employee?
  end

  helper_method :warehouse_employee?

  def customer_service_employee?
    current_user.customer_service_employee?
  end

  helper_method :customer_service_employee?

  def sign_in_as(employee)
    session[:employee_id] = employee.id
  end

  def sign_out
    session[:employee_id] = nil
  end

  def signed_out?
    !signed_in?
  end
end
