require 'test_helper'

class ScheduleCategoryTest < ActiveSupport::TestCase
  test 'validation name' do
    @account = accounts(:account)

    schedule_category = ScheduleCategory.new account_id: @account.id

    assert_not schedule_category.valid?
  end
end
