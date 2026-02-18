class CalendarEventsController < ApplicationController
  def index
    @date = date_param
    @bookings = Current.account.bookings.for_today(@date)
  end

    private

      def date_param
        Date.parse(params[:date])
      rescue
        Date.current
      end
end
