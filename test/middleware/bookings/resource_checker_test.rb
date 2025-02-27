require 'test_helper'

class Bookings::ResourceCheckerTest < ActiveSupport::TestCase
  test 'valid booking' do
    booking = user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    assert_equal [], Bookings::ResourceChecker.new(user.id, resource.id, Date.today,
                                                   schedule_category2.id, 8).call
  end

  test 'invalid taken by other user' do
    booking = user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    assert_equal [ I18n.t('bookings.errors.takenByOtherUser') ], Bookings::ResourceChecker.new(user2.id, resource.id, Date.today,
                                                                                             schedule_category.id, 8).call
  end

  test 'invalid taken by user' do
    booking = user.bookings.create schedule_category:, start_on: Date.today, participants: 10
    booking.resource_bookings.create resource_id: resource.id

    assert_equal [ I18n.t('bookings.errors.takenByUser') ], Bookings::ResourceChecker.new(user.id, resource.id, Date.today,
                                                                                        schedule_category.id, 8).call
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

  def schedule_category
    @schedule_category ||= schedule_categories(:schedule_category)
  end

  def schedule_category2
    @schedule_category2 ||= schedule_categories(:schedule_category2)
  end
end
