class CalendarController < ApplicationController
  before_action :find_date

  def index
    monthly_info = Bookings::Calendar.call Current.account, @date.strftime("%Y-%m")
    @weeks = monthly_info.each_slice(7)
  end

  private

    def find_date
      @date = if params[:date].blank?
        Date.current
      else
        Date.parse(params[:date])
      end
    end
end
