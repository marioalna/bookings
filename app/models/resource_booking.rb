class ResourceBooking < ApplicationRecord
  belongs_to :resource
  belongs_to :booking
end
