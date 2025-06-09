class BookingsController < ApplicationController
  before_action :find_booking, only: %i[edit update destroy]
  before_action :find_schedule_categories, only: %i[new check create edit update]
  before_action :find_resources, only: %i[new create edit update]
  before_action :find_date, only: %i[index]
  before_action :find_bookings, only: %i[index]

  def index
  end

  def new
    @booking = Current.user.bookings.new start_on: booking_date, schedule_category_id: @schedule_categories.first[0]
    @booking_custom_attributes = @booking.booking_custom_attributes.build
    available_resources
    current_info
    custom_attributes
  end

  def create
    @booking =  Current.user.bookings.create booking_params

    if @booking.persisted?
      Bookings::BookingCustomAttributes.new(@booking, params[:custom_attribute_ids], Current.account).create
      redirect_to bookings_path, notice: t("bookings.created")
    else
      available_resources
      current_info
      custom_attributes
      render "new", status: :unprocessable_entity
    end
  end

  def edit
    available_resources
    current_info
    custom_attributes(true)
  end

  def update
    if @booking.update(booking_params)
      Bookings::BookingCustomAttributes.new(@booking, params[:custom_attribute_ids], Current.account).update
      redirect_to bookings_path, notice: t("bookings.updated")
    else
      available_resources
      current_info
      custom_attributes(true)
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    @booking.destroy

    redirect_to bookings_path, notice: t("bookings.deleted")
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

    def find_schedule_categories
      @schedule_categories = Current.account.schedule_categories.pluck(:id, :name)
    end

    def find_resources
      @resources = Current.account.resources
        .includes(:resource_bookings).order(max_capacity: :desc)
    end

    def find_booking
      @booking = if Current.user.admin?
        Current.account.bookings.find params[:id]
      else
        Current.user.bookings.find params[:id]
      end
    end

    def custom_attributes(edit = false)
      @custom_attributes = Bookings::CustomAttributes.new(Current.user, start_on, schedule_category_id, edit).call
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
      @available_resources, @errors = Bookings::AvailableResources.new(Current.user.id, start_on, schedule_category_id).call
    end

    def current_info
      info = Bookings::CurrentInfo.new(Current.account, start_on, schedule_category_id).call

      @num_bookings = info[:num_bookings]
      @participants = info[:participants]
      @schedule_name = info[:schedule_name]
    end

    def find_bookings
      @bookings = Bookings::Finder.new(Current.account, params, @start_date..@end_date).call
    end

    def find_date
      @start_date = booking_date.beginning_of_month
      @end_date = booking_date.end_of_month
    end

    def booking_date
      return Date.current if params[:date].blank?

      Date.parse params[:date]
    rescue
      Date.current
    end
end
