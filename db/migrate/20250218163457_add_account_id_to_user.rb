class AddAccountIdToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :account_id, :bigint

    add_index :users, %i[account_id email_address], unique: true
  end
end
