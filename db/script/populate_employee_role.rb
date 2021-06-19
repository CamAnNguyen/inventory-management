Employee.all.each do |employee|
  employee.update!(role: 'WarehouseEmployee')
end
