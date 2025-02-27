require "test_helper"

class Bookings::AvailableResourcesTest < ActiveSupport::TestCase
  test "valid booking" do
    booking = user.bookings.create! schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create! resource_id: resource.id
    booking = user.bookings.create! schedule_category: schedule_category2, start_on: Date.today, participants: 8
    booking.resource_bookings.create! resource_id: resource2.id

    assert_equal 1, Bookings::AvailableResources.new(
      user.id, Date.today, schedule_category2.id).call.first.count
  end

  test "valid booking only 1 resource" do
    booking = user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    booking = user.bookings.create schedule_category: schedule_category2, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource2.id

    assert_equal 1, Bookings::AvailableResources.new(user.id, Date.today,
                                                     schedule_category2.id).call.first.count
  end

  test "invalid booking" do
    booking = user.bookings.create schedule_category: schedule_category2, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    booking = user2.bookings.create schedule_category: schedule_category2, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource2.id

    assert Bookings::AvailableResources.new(user.id, Date.today,
                                            schedule_category2.id).call.first.empty?
  end

  test "invalid date" do
    booking = user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    booking = user2.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource2.id

    assert_equal [ I18n.t("bookings.errors.invalidDate") ], Bookings::AvailableResources.new(user.id, Date.today - 2,
                                                     schedule_category2.id).call.last
  end

  test "invalid schedule id" do
    booking = user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    booking = user2.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource2.id

    assert_equal [ I18n.t("bookings.errors.invalidSchedule") ], Bookings::AvailableResources.new(user.id, Date.today,
                                                     145).call.last
  end

  private

    def user
      @user ||= users(:admin)
    end

    def user2
      @user2 ||= users(:regular)
    end

    def resource
      @resource ||= resources(:resource)
    end

    def resource2
      @resource2 ||= resources(:resource2)
    end

    def schedule_category
      @schedule_category ||= schedule_categories(:schedule_category)
    end

    def schedule_category2
      @schedule_category2 ||= schedule_categories(:schedule_category2)
    end
end
