class AddRoleToEmployees < ActiveRecord::Migration[6.0]
  def change
    add_column :employees, :role, :string
  end
end
