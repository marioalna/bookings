module Bookings
  class Finder
    def initialize(account, params, dates_range)
      @account = account
      @params = params
      @dates_range = dates_range
    end

    def call
      if user_id.present?
        account.bookings.where(start_on: dates_range, user_id: params[:user_id]).includes(:custom_attributes).order(:start_on, :schedule_category_id)
      elsif resource_id.present?
        account.bookings.joins(:resources).where(start_on: dates_range, resources: { id: resource_id }).includes(:custom_attributes).order(:start_on, :schedule_category_id)
      else
        account.bookings.where(start_on: dates_range).includes(:custom_attributes).order(:start_on, :schedule_category_id)
      end
    end

    private

      attr_reader :account, :params, :dates_range

      def user_id
        account.users.find_by(id: params[:user_id])&.id
      end

      def resource_id
        account.resources.find_by(id: params[:resource_id])&.id
      end
  end
end
