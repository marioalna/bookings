class AddUserValues < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_column :users, :username, :string, null: :false
    rename_column :users, :email_address, :email
    add_column :users, :forget_token, :string
    add_column :users, :role, :integer, default: 0
    add_column :users, :forget_expires_at, :datetime
    add_column :users, :active, :boolean, default: :true
  end
end
