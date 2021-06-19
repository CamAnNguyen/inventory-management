class AddDefaultValueToEmployeeRole < ActiveRecord::Migration[6.0]
  def up
    change_column_default(:employees, :role, 'WarehouseEmployee')
  end

  def down
    change_column_default(:employees, :role, nil)
  end
end
