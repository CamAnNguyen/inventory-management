class RegistrationsController < ApplicationController
  def new
    @roles = Employee.descendants.map do |klass|
      [klass.to_s.underscore.humanize.titleize, klass.to_s]
    end
  end

  def create
    employee = Employee.new(employee_params)

    if employee.save
      sign_in_as(employee)
      redirect_to employees_path
    else
      render :new
    end
  end

  def destroy
    redirect_to root_path
  end

  def employee_params
    params.require(:registration).permit(:access_code, :name, :role)
  end
end
