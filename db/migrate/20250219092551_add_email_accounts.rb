class AddEmailAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :email, :string, null: :false
  end
end
