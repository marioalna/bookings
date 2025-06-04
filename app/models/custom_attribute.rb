class CustomAttribute < ApplicationRecord
  belongs_to :account

  has_many :booking_custom_attributes
  has_many :bookings, through: :booking_custom_attributes

  validates :name, presence: true
end
