module Bookings
  class BlockSchedule
    def initialize(user, date, schedule_category_id)
      @user = user
      @account = user.account
      @date = date
      @schedule_category_id = schedule_category_id
    end

    def call
      Booking.transaction do
        account.bookings.where(start_on: date, schedule_category_id: schedule_category_id).destroy_all

        booking = user.bookings.create!(
          start_on: date,
          schedule_category_id: schedule_category_id,
          participants: 0,
          blocked: true
        )

        account.resources.each do |resource|
          booking.resource_bookings.create!(resource_id: resource.id)
        end

        booking
      end
    end

    private

      attr_reader :user, :account, :date, :schedule_category_id
  end
end
