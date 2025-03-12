require 'test_helper'

class Accounts::NewAccountTest < ActiveSupport::TestCase
  test 'create account and user' do
    params = { account: { account_name: 'New account', user_name: 'username', email: 'test@test.com' } }

    assert_difference 'Account.count', 1 do
      assert_difference 'User.count', 1 do
        assert Accounts::NewAccount.new(params).call
      end
    end
  end
end
