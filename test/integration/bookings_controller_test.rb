require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_admin
  end

  test "index" do
    get bookings_path

    assert_response :success
  end

  test "new" do
    get new_booking_path

    assert_response :success
  end

  test "should create a booking" do
    schedule_category = schedule_categories(:schedule_category)
    resource = resources(:resource)
    params = { booking: { start_on: 3.days.from_now, schedule_category_id: schedule_category.id, participants: 5, resource_bookings_attributes: { "0": { resource_id: resource.id }, "1": { resource_id: "" } } } }

    post bookings_path, params: params

    assert_response :redirect

    booking = Booking.last

    assert_equal 3.days.from_now.to_date, booking.start_on
    assert_equal schedule_category.id, booking.schedule_category_id
    assert_equal 5, booking.participants
    assert_equal 1, booking.resource_bookings.count
  end
end
