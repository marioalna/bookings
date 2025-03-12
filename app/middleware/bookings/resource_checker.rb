module Bookings
  class ResourceChecker
    def initialize(user_id, resource_id, date, schedule_category_id, capacity)
      @user_id = user_id
      @resource_id = resource_id
      @date = date
      @schedule_category_id = schedule_category_id
      @capacity = capacity
      @errors = []
    end

    def call
      validate_date
      validate_capacity

      errors
    end

    private

    attr_reader :user_id, :resource_id, :date, :schedule_category_id, :capacity, :errors

    def validate_date
      taken_resource_booking = resource.bookings.where(start_on: date).where(schedule_category_id:)&.first

      return if taken_resource_booking.blank?

      errors << if taken_resource_booking.user == user
                  I18n.t('bookings.errors.takenByUser')
                else
                  I18n.t('bookings.errors.takenByOtherUser')
                end
    end

    def validate_capacity
      return if capacity.nil?
      return if resource.max_capacity >= capacity

      errors << I18n.t('bookings.errors.invalidCapacity')
    end

    def user
      @user ||= User.find user_id
    end

    def resource
      @resource ||= user.account.resources.find resource_id
    end
  end
end
