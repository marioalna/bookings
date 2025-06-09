module Bookings
  class ResourceChecker
    def initialize(current_user, **resource)
      @current_user = current_user
      @account = account
      @resource_id = resource[:resource_id]
      @date = resource[:date]
      @schedule_category_id = resource[:schedule_category_id]
      @capacity = resource[:capacity]
      @errors = []
    end

    def call
      validate_booked_on_date
      validate_capacity

      errors
    end

    private

    attr_reader :current_user, :resource_id, :date, :schedule_category_id, :capacity, :errors

    def validate_booked_on_date
      taken_resource_booking = resource.bookings.where(start_on: date).where(schedule_category_id:).where.not(user_id: current_user.id)&.first

      return if taken_resource_booking.blank?

      errors << if taken_resource_booking.user == current_user
        I18n.t('bookings.errors.takenByUser')
      else
        I18n.t('bookings.errors.takenByOtherUser')
      end
    end

    def validate_capacity
      return if capacity.nil? || resource.max_capacity >= capacity

      errors << I18n.t('bookings.errors.invalidCapacity')
    end

    def resource
      @resource ||= account.resources.find resource_id
    end

    def account
      @account ||= current_user.account
    end
  end
end
