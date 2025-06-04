class BookingCustomAttribute < ApplicationRecord
  belongs_to :booking
  belongs_to :custom_attribute
end
