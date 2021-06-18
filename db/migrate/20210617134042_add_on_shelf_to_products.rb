class AddOnShelfToProducts < ActiveRecord::Migration[6.0]
  def self.up
    add_column :products, :on_shelf, :integer, null: false, default: 0
  end

  def self.down
    remove_column :products, :on_shelf
  end
end
