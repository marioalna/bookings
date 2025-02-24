class CalendarController < ApplicationController
  def index
    monthly_info = Bookings::Calendar.call Current.account, date
    @weeks = monthly_info.each_slice(7)
  end

  private

    def date
      params[:date].presence || Date.current.strftime("%Y-%m")
    end
end
