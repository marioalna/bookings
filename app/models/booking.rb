class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :schedule_category

  has_many :resource_bookings
  has_many :resources, through: :resource_bookings
  has_many :booking_custom_attributes
  has_many :custom_attributes, through: :booking_custom_attributes

  normalizes :colour, with: ->(colour) { colour&.downcase }

  validates :start_on, presence: true
  validates :schedule_category_id, presence: true
  validates :start_on, comparison: { greater_than_or_equal_to: Date.current }, unless: :current_user_is_admin?
  validates :participants, comparison: { greater_than_or_equal_to: 0 }
  validates_uniqueness_of :user_id, scope: [ :schedule_category_id, :start_on ], message: ->(_record, _data) { I18n.t('bookings.errors.userTaken') }
  validates :colour, inclusion: { in: AVAILABLE_COLOURS }, allow_nil: true
  validate :schedule_not_blocked, on: :create

  before_create :assign_end_on

  before_validation :downcase_colour

  accepts_nested_attributes_for :resource_bookings, allow_destroy: true, reject_if: :all_blank

  scope :for_today, ->(date) { joins(:schedule_category).where(start_on: date) }
  scope :blocked_for, ->(date, schedule_category_id) { where(start_on: date, schedule_category_id: schedule_category_id, blocked: true) }

  private

    def assign_end_on
      self.end_on = start_on if end_on.blank?
    end

    def schedule_not_blocked
      return if blocked?

      if Current.account&.bookings&.blocked_for(start_on, schedule_category_id)&.exists?
        errors.add(:base, I18n.t("bookings.errors.scheduleBlocked"))
      end
    end

    def current_user_is_admin?
      Current.user&.admin?
    end

    def downcase_colour
      self.colour&.downcase!
    end
end
