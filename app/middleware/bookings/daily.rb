module Bookings
  class Daily
    def initialize(account, date)
      @account = account
      @date = date
    end

    def call
      bookings
    end

    private

      attr_reader :account, :date

      def bookings
        @bookings ||= account.bookings
        .joins(:schedule_category)
        .where(start_on: date)
      end
  end
end
