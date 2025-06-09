require 'test_helper'

class Bookings::CustomAttributesCheckerTest < ActiveSupport::TestCase
  test 'custom attributes available' do
    booking = user.bookings.create(
      schedule_category:,
      start_on: Date.today,
      participants: 5
    )
    booking_custom_attribute = booking.booking_custom_attributes.create(custom_attribute_id: custom_attribute.id)
    custom_attribute2

    result = Bookings::CustomAttributes.new(users(:admin), Date.today, schedule_category.id).call

    assert_equal custom_attribute, result[:not_available].first
     assert_equal custom_attribute2, result[:available].first
  end

  private

  def user
    @user ||= users(:admin)
  end

  def create_bookings
    booking_1 = user.bookings.create(
      schedule_category:,
      start_on: Date.today,
      participants: 5
    )
    booking_custom_attribute = booking_1.booking_custom_attributes custom_attribute_id: custom_attribute.id
  end

  def schedule_category
    @schedule_category ||= schedule_categories(:schedule_category)
  end

  def custom_attribute
    @custom_attribute ||= custom_attributes(:custom_attribute)
  end

  def custom_attribute2
    @custom_attribute2 ||= accounts(:account).custom_attributes.create(name: "custom attr 2", block_on_schedule: true)
  end
end
