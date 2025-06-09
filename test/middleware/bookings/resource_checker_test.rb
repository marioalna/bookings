require 'test_helper'

class Bookings::ResourceCheckerTest < ActiveSupport::TestCase
  test 'valid booking' do
    booking = user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    assert_equal [], Bookings::ResourceChecker.new(
      user, resource_id: resource.id, date: Date.today,
        schedule_category_id: schedule_category2.id, capacity: 8
    ).call
  end

  test 'invalid taken by other user' do
    booking = regular_user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    assert_equal [ I18n.t('bookings.errors.takenByOtherUser') ], Bookings::ResourceChecker.new(
      user, resource_id: resource.id, date: Date.today, schedule_category_id: schedule_category.id, capacity: 8
    ).call
  end

  test 'valid if taken by same user' do
    booking = user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    assert_equal [], Bookings::ResourceChecker.new(
      user, resource_id: resource.id, date: Date.today, schedule_category_id: schedule_category.id, capacity: 8
    ).call
  end

  private

  def user
    @user ||= users(:admin)
  end

  def regular_user
    @regular_user ||= users(:regular)
  end

  def resource
    @resource ||= resources(:resource)
  end

  def schedule_category
    @schedule_category ||= schedule_categories(:schedule_category)
  end

  def schedule_category2
    @schedule_category2 ||= schedule_categories(:schedule_category2)
  end
end
