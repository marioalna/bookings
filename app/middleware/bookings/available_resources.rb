module Bookings
  class AvailableResources
    def initialize(user_id, date, schedule_category_id)
      @user_id = user_id
      @date = date
      @schedule_category_id = schedule_category_id
      @available_resources = []
      @errors = []
    end

    def call
      validate_params
      assign_resources

      errors << I18n.t("bookings.errors.noResourcesAvailable") if available_resources.empty?

      [ available_resources, errors ]
    end

    private

      attr_reader :user_id, :date, :schedule_category_id, :available_resources, :errors

      def assign_resources
        resources.each do |resource|
          if Bookings::ResourceChecker.new(user.id, resource.id, date, schedule_category_id, nil).call.empty?
            available_resources << resource
          end
        end
      end

      def validate_params
        schedule_category = user.account.schedule_categories.find_by id: schedule_category_id
        errors  << I18n.t("bookings.errors.invalidDate") if date.to_date < Date.today
        errors  << I18n.t("bookings.errors.invalidSchedule") unless schedule_category
      end

      def user
        @user ||= User.find user_id
      end

      def resources
        @resources ||= user.account.resources
      end
  end
end
