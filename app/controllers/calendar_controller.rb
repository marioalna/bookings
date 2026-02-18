class CalendarController < ApplicationController
  before_action :find_date
  before_action :find_schedule_categories, only: %i[new create]
  before_action :find_resources, only: %i[new create]

  def index
    monthly_info = Bookings::Calendar.call Current.account, @date.strftime("%Y-%m")
    @weeks = monthly_info.each_slice(7).to_a
    @total_weeks = @weeks.size
    @current_week_index = current_week_index
  end

  def new
    @booking = Current.user.bookings.new start_on: booking_date, schedule_category_id: @schedule_categories.first[0]
    available_resources
    current_info
    custom_attributes
  end

  def create
    @booking =  Current.user.bookings.create booking_params

    if @booking.persisted?
      Bookings::BookingCustomAttributes.new(@booking, params[:custom_attribute_ids], Current.account).create
      flash.now[:notice] = t('bookings.created')
      @day = {
        day: @booking.start_on,
        bookings: bookings_for_day
      }
    else
      available_resources
      current_info
      custom_attributes
    end
  end

  def check
    available_resources
    current_info
    custom_attributes
  end

  private

    def booking_params
      params.require(:booking).permit(:start_on, :schedule_category_id, :participants, resource_bookings_attributes: %i[resource_id])
    end

    def find_date
      @date = if params[:date].blank?
        Date.current
      else
        Date.parse(params[:date])
      end
    end

    def custom_attributes
      @custom_attributes = Bookings::CustomAttributes.new(Current.user, start_on, schedule_category_id).call
    end

    def find_schedule_categories
      @schedule_categories = Current.account.schedule_categories.pluck(:id, :name)
    end

    def find_resources
      @resources = Current.account.resources
        .includes(:resource_bookings).order(max_capacity: :desc)
    end

    def start_on
      return @booking.start_on if params[:booking].blank? || params[:booking][:start_on].blank?

      params[:booking][:start_on]
    end

    def schedule_category_id
      return @booking.schedule_category_id if params[:booking].blank? || params[:booking][:schedule_category_id].blank?

      params[:booking][:schedule_category_id]
    end

    def available_resources
      @available_resources, @errors = Bookings::AvailableResources.new(Current.user, start_on, schedule_category_id).call
    end

    def current_info
      info = Bookings::CurrentInfo.new(Current.account, start_on, schedule_category_id).call

      @num_bookings = info[:num_bookings]
      @participants = info[:participants]
      @schedule_name = info[:schedule_name]
    end

    def bookings_for_day
      Current.account.bookings
                  .for_today(start_on)
                  .group(:start_on, :schedule_category_id)
                  .select("bookings.start_on, sum(bookings.participants) as participants, schedule_categories.name as schedule_category_name, schedule_categories.colour as schedule_category_colour")
    end

    def current_week_index
      target = (@date.month == Date.current.month && @date.year == Date.current.year) ? Date.current : @date.beginning_of_month
      @weeks.each_with_index do |week, i|
        return i if week.any? { |day| day[:day] == target }
      end
      0
    end

    def booking_date
      return Date.current if params[:date].blank?

      Date.parse params[:date]
    rescue
      Date.current
    end
end
