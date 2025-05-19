require "test_helper"

class Bookings::CurrentInfoTest < ActiveSupport::TestCase
  test "call" do
    result = Bookings::CurrentInfo.new(account, Date.current.beginning_of_month, schedule_category.id).call

    assert_equal 2, result[:num_bookings]
    assert_equal 22, result[:participants]
    assert_equal schedule_category.name, result[:schedule_name]
  end

  private

    def account
      @account ||= accounts(:account)
    end

    def schedule_category
      @schedule_category ||= schedule_categories(:schedule_category)
    end
end
