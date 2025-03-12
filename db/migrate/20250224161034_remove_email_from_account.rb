class RemoveEmailFromAccount < ActiveRecord::Migration[8.0]
  def change
    remove_column :accounts, :email, :string
  end
end
