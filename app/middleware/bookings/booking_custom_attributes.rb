module Bookings
  class BookingCustomAttributes
    def initialize(booking, custom_attribute_ids, account)
      @booking = booking
      @custom_attribute_ids = custom_attribute_ids
      @account = account
    end

    def create
      return if custom_attribute_ids.nil?

      custom_attribute_ids.each do |id|
        return unless valid_id?(id)

        booking.booking_custom_attributes.create custom_attribute_id: id
      end
    end

    def update
      booking.booking_custom_attributes.delete_all

      return if custom_attribute_ids.nil?

      custom_attribute_ids.each do |id|
        return unless valid_id?(id)

        booking.booking_custom_attributes.create custom_attribute_id: id
      end
    end

    private

      attr_reader :booking, :custom_attribute_ids, :account

      def valid_id?(id)
        custom_attribute =  account.custom_attributes.find id

        custom_attribute.present?
      end
  end
end
