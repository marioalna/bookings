module Bookings
  class AvailableResources
    def initialize(current_user, date, schedule_category_id)
      @current_user = current_user
      @date = date
      @schedule_category_id = schedule_category_id
      @available_resources = []
      @errors = []
    end

    def call
      validate_params
      assign_resources if errors.empty?

      errors << I18n.t("bookings.errors.noResourcesAvailable") if available_resources.empty? && errors.empty?

      [ available_resources, errors ]
    end

    private

      attr_reader :current_user, :date, :schedule_category_id, :available_resources, :errors

      def assign_resources
        resources.each do |resource|
          if Bookings::ResourceChecker.new(current_user, resource_id: resource.id, date:, schedule_category_id:).call.empty?
            available_resources << resource
          end
        end
      end

      def validate_params
        schedule_category = account.schedule_categories.find_by id: schedule_category_id

        if date.nil?
          errors << I18n.t("bookings.errors.invalidDate")
        elsif date.to_date < Date.today
          errors << I18n.t("bookings.errors.invalidDate")
        end

        errors << I18n.t("bookings.errors.invalidSchedule") unless schedule_category

        if errors.empty? && !current_user.admin? && account.bookings.blocked_for(date, schedule_category_id).exists?
          errors << I18n.t("bookings.errors.scheduleBlocked")
        end
      end

      def account
        @account ||= current_user.account
      end

      def resources
        @resources ||= account.resources
      end
  end
end
