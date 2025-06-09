require 'test_helper'

class Bookings::CustomAttributesTest < ActiveSupport::TestCase
  test 'one custom attribute available' do
    booking = regular_user.bookings.create(
      schedule_category:, start_on: Date.today, participants: 5
    )
    booking.booking_custom_attributes.create(custom_attribute_id: custom_attribute.id)
    custom_attribute2

    result = Bookings::CustomAttributes.new(users(:admin), Date.today, schedule_category.id).call

    assert_equal custom_attribute, result[:not_available].first
    assert_equal custom_attribute2, result[:available].first
  end

  test 'all custom attributes available' do
    custom_attribute2

    result = Bookings::CustomAttributes.new(users(:admin), Date.today, schedule_category.id).call

    assert result[:not_available].empty?
    assert result[:available].include? custom_attribute
    assert result[:available].include? custom_attribute2
  end

  private

  def user
    @user ||= users(:admin)
  end

  def regular_user
    @regular_user ||= users(:regular)
  end

  def create_bookings
    booking_1 = user.bookings.create(
      schedule_category:,
      start_on: Date.today,
      participants: 5
    )
    booking_1.booking_custom_attributes custom_attribute_id: custom_attribute.id
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
