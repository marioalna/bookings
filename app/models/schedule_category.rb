class ScheduleCategory < ApplicationRecord
  belongs_to :account

  validates :name, presence: true
  validates :colour, inclusion: { in: AVAILABLE_COLOURS }, allow_nil: true
end
