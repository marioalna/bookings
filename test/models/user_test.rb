require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'validation username and password' do
    user = User.new email: 'email@test.com'

    assert_not user.valid?
  end
end
