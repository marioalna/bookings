require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test 'validation name' do
    account = Account.new email: 'email@test.com'

    assert_not account.valid?
  end

  test 'validation email' do
    account = Account.new name: 'test name'

    assert_not account.valid?
  end
end
