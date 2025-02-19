require 'test_helper'

class ResourceTest < ActiveSupport::TestCase
  test 'validation name' do
    @account = accounts(:account)

    resource = Resource.new account_id: @account.id

    assert_not resource.valid?
  end
end
