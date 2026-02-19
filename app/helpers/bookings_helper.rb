module BookingsHelper
  def can_edit?(booking)
    Current.user.role == User::ADMIN || (booking.user == Current.user && booking.start_on >= Date.current)
  end

  def resources_for_frontend(resources)
    resources.each_with_object({}) do |resource, result|
      result[resource.id] = {
        name: resource.name,
        max_capacity: resource.max_capacity
      }
    end
  end

  def capacity_for_frontend(available_resources)
    capacity = 0

    available_resources.each do |resource|
      capacity += resource.max_capacity
    end
    capacity
  end

  def translations_for_frontend
    {
      "notEnough": {
        translation: I18n.t('bookings.assign.notEnough')
      },
      "enough": {
        translation: I18n.t('bookings.assign.enough')
      },
      "exceeded": {
        translation: I18n.t('bookings.assign.exceeded')
      },
      "blocked": {
        translation: I18n.t('bookings.blocked')
      }
    }
  end
end
