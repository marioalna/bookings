require "test_helper"

class Bookings::AvailableResourcesTest < ActiveSupport::TestCase
  test "valid booking" do
    booking = user.bookings.create! schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create! resource_id: resource.id
    booking = user.bookings.create! schedule_category: schedule_category2, start_on: Date.today, participants: 8
    booking.resource_bookings.create! resource_id: resource2.id
    available_resources = Bookings::AvailableResources.new(user, Date.current, schedule_category2.id).call

    assert_equal 2, available_resources.first.count
  end

  test "valid booking only 1 resource" do
    booking = user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    other_booking = user2.bookings.create schedule_category: schedule_category2, start_on: Date.today, participants: 10
    other_booking.resource_bookings.create resource_id: resource2.id
    available_resources = Bookings::AvailableResources.new(user, Date.current, schedule_category2.id).call

    assert_equal 1, available_resources.first.count
  end

  test "invalid booking" do
    booking = user.bookings.create schedule_category: schedule_category2, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    booking = user2.bookings.create schedule_category: schedule_category2, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource2.id
    available_resources = Bookings::AvailableResources.new(
      user, Date.current, schedule_category2.id
    ).call

    assert available_resources.last.empty?
  end

  test "invalid date" do
    booking = user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    booking = user2.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource2.id
    available_resources = Bookings::AvailableResources.new(user, 2.days.ago, schedule_category.id).call

    assert_equal [ I18n.t("bookings.errors.invalidDate") ], available_resources.last
  end

  test "nil date" do
    available_resources, errors = Bookings::AvailableResources.new(user, nil, schedule_category.id).call

    assert_equal [I18n.t("bookings.errors.invalidDate")], errors
    assert_empty available_resources
  end

  test "invalid schedule id" do
    booking = user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    booking = user2.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource2.id
    available_resources = Bookings::AvailableResources.new(user, Date.today, 145).call

    assert_equal [ I18n.t("bookings.errors.invalidSchedule") ], available_resources.last
  end

  private

    def account
      @account ||= accounts(:account)
    end

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
