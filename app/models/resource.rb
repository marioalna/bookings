class Resource < ApplicationRecord
  belongs_to :account

  has_one_attached :photo

  has_many :resource_bookings
  has_many :bookings, through: :resource_bookings

  validates :name, presence: true
end
