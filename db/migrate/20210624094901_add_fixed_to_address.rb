class AddFixedToAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :fixed, :boolean
  end
end
