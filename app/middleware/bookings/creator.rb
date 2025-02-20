module Bookings
  class Creator
    def initialize(user_id, params)
      @user_id = user_id
      @start_on = params[:start_on]
      @schedule_category_id = params[:schedule_category_id]
      @resource_ids = params[:resource_bookings]
      @participants = params[:participants]
    end

    def call
      booking = user.bookings.create(start_on:, schedule_category_id:, participants:)

      if booking.persisted?
        resources.each do |resource|
          booking.resource_bookings.create resource_id: resource.id
        end
        true
      else
        false
      end
    end

    private

      attr_reader :start_on, :schedule_category_id, :resource_ids, :user_id, :participants

      def resources
        @resources ||= available_resources
      end

      def available_resources
        valid_resources = []

        resource_ids.each do |resource_id|
          resource = user.account.resources.find_by id: resource_id
          valid_resources << resource if !resource.nil?
        end

        valid_resources
      end

      def user
        @user ||= User.find user_id
      end
  end
end
