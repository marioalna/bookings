module Bookings
  class Calendar
    class << self
      def call(account, date)
        new(account, date).call
      end
    end

    def initialize(account, date)
      @account = account
      @date = date
    end

    def call
      results
    end

    private

      attr_reader :account, :date

      def results
        month_days.map do |day|
          {
            day: day,
            bookings: bookings.select { |booking| booking.start_on == day }
          }
        end
      end


      def month_days
        (first_day..last_day).to_a
      end

      def bookings
        @bookings ||= account.bookings
        .joins(:schedule_category)
        .where(start_on: first_day..last_day)
        .group(:start_on, :schedule_category_id)
        .select("bookings.start_on, sum(bookings.participants) as participants, schedule_categories.name as schedule_category_name, schedule_categories.colour as schedule_category_colour, MAX(CASE WHEN bookings.blocked = 1 THEN 1 ELSE 0 END) as schedule_blocked")
      end

      def first_day
        start_date.beginning_of_month.beginning_of_week
      end

      def last_day
        start_date.end_of_month.end_of_week
      end

      def start_date
        @start_date = Date.parse("#{date}-1")
      end
  end
end
