module ResourcesHelper
  def selected_resource_booking(params, resource_booking_id)
    if params[:booking].present? && params[:booking][:resource_bookings_attributes].present?
      return params[:booking][:resource_bookings_attributes][resource_booking_id.to_s][:resource_id]
    end

    return resource_booking_id if @booking&.persisted? && @booking.resource_ids.include?(resource_booking_id)

    ""
  end

  def resource_image(resource)
    if resource.photo.attached?
      url_for resource.photo
    else
      "default.jpg"
    end
  end
end
