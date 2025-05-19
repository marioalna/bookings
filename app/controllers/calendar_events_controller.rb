class CalendarEventsController < ApplicationController
  def index
    @bookings = Current.account.bookings.for_today(date)
  end

    private

      def date
        params[:date] || Date.current.to_s
      end
end
