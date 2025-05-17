module Bookings
  class CurrentInfo
    def initialize(account, start_on, schedule_category_id)
      @account = account
      @start_on = start_on
      @schedule_category_id = schedule_category_id
    end

    def call
      @num_bookings = 0
      @participants = 0

      @schedule_name = account.schedule_categories.find(schedule_category_id).name

      bookings = account.bookings.where(start_on:, schedule_category_id:)
      bookings.each do |booking|
        @num_bookings += 1
        @participants += booking.participants
      end
    end

    private

      attr_reader :account, :schedule_category_id, :start_on
  end
end
