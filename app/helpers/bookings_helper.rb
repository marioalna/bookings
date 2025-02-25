module BookingsHelper
  def can_edit?(booking)
    Current.user.role == User::ADMIN || ( booking.user == Current.user && booking.start_on >= Date.current )
  end

  def resources_for_frontend(resources)
    resources.each_with_object({}) do |resource, result|
      result[resource.id] = {
        name: resource.name,
        max_capacity: resource.max_capacity
      }
    end
  end
end
