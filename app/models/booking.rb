class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :schedule_category

  has_many :resource_bookings
  has_many :resources, through: :resource_bookings

  normalizes :colour, with: ->(colour) { colour&.downcase }

  validates :start_on, presence: true
  validates :schedule_category_id, presence: true
  validates :start_on, comparison: { greater_than_or_equal_to: Date.current }
  validates :participants, comparison: { greater_than_or_equal_to: 0 }
  validates_uniqueness_of :user_id, scope: [ :schedule_category_id, :start_on ]
  validates :colour, inclusion: { in: AVAILABLE_COLOURS }, allow_nil: true

  before_create :assign_end_on

  before_validation :downcase_colour

  accepts_nested_attributes_for :resource_bookings, allow_destroy: true, reject_if: :all_blank

  private

    def assign_end_on
      self.end_on = start_on if end_on.blank?
    end

    def downcase_colour
      self.colour&.downcase!
    end
end
