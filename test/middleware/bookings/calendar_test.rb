require "test_helper"

class Bookings::CalendarTest < ActiveSupport::TestCase
  test "call" do
    result = Bookings::Calendar.call account, Date.current.strftime("%Y-%m")

    assert_equal 1, result.find { |r| r[:day] == Date.current.beginning_of_month }[:bookings].size
  end

  private

    def account
      @account ||= accounts(:account)
    end
end
