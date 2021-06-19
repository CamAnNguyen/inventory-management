class AddReturnedStatusToInventoryStatusChange < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      ALTER TYPE inventory_statuses ADD VALUE 'returned';
    SQL
  end

  def down
    execute <<-SQL
      ALTER TYPE inventory_statuses DROP VALUE 'returned';
    SQL
  end
end
