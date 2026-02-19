require "test_helper"

class BookingTest < ActiveSupport::TestCase
  test "blocked defaults to false" do
    booking = Booking.new
    assert_equal false, booking.blocked
  end

  test "blocked_for scope returns blocked bookings" do
    blocked = bookings(:blocked_booking)
    results = Booking.blocked_for(blocked.start_on, blocked.schedule_category_id)

    assert_includes results, blocked
  end

  test "blocked_for scope does not return regular bookings" do
    regular = bookings(:booking1_sc1)
    results = Booking.blocked_for(regular.start_on, regular.schedule_category_id)

    assert_not_includes results, regular
  end
end
