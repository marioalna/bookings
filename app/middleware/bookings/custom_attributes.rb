module Bookings
  class CustomAttributes
    def initialize(user, date, schedule_category_id, edit)
      @user = user
      @date = date
      @schedule_category_id = schedule_category_id
      @edit = edit
    end

    def call
      not_available_attributes = []
      available_attributes = []

      custom_attributes.each do |custom_attribute|
        next unless custom_attribute.block_on_schedule
        if invalid_attribute?(custom_attribute)
          not_available_attributes << custom_attribute
        else
          available_attributes << custom_attribute
        end
      end

      { not_available: not_available_attributes, available: available_attributes }
    end

    private

      attr_reader :user, :date, :schedule_category_id, :edit

      def bookings_for_today
        @bookings_for_today ||= user.account.bookings.where(start_on: date).where(schedule_category_id:)
      end

      def custom_attributes
        @custom_attributes ||= user.account.custom_attributes
      end

      def invalid_attribute?(custom_attribute)
        if edit
          bookings_for_today.includes(:booking_custom_attributes)
            .where(booking_custom_attributes: { custom_attribute_id: custom_attribute.id })
            .where.not(user_id: user.id)
            .present?
        else
          bookings_for_today.includes(:booking_custom_attributes)
            .where(booking_custom_attributes: { custom_attribute_id: custom_attribute.id })
            .present?
        end
      end
    # .where.not(user_id: user.id)
  end
end
