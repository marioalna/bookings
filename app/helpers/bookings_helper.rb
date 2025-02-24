module BookingsHelper
  def can_edit?(booking)
    Current.user.role == User::ADMIN || ( booking.user == Current.user && booking.start_on >= Date.current )
  end
end