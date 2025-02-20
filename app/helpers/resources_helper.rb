module ResourcesHelper
  def selected_resource_booking(params, resource_booking_id)
    return "" if params[:booking].blank? || params[:booking][:resource_bookings_attributes].blank?

    params[:booking][:resource_bookings_attributes][resource_booking_id.to_s][:resource_id]
  end

  def resource_image(resource)
    if resource.photo.attached?
      url_for resource.photo
    else
      "default.jpg"
    end
  end
end
