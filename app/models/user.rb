class User < ApplicationRecord
  has_secure_password

  attribute :role

  REGULAR = "regular".freeze
  ADMIN = "admin".freeze

  belongs_to :account

  has_many :bookings
  has_many :sessions, dependent: :destroy

  validates :name, presence: true
  validates :username, uniqueness: true, length: { in: 3..25 },
                       format: {
                         with: /\A[a-z0-9A-Z]+\z/,
                         message: :invalid
                       }
  validates :email, format: {
    with: /\A([\w+-].?)+@[a-z\d-]+(\.[a-z]+)*\.[a-z]+\z/i,
    message: :invalid
  }

  enum :role, { regular: 0, admin: 9 }

  before_save :downcase_attributes

  class << self
    def validate_reset_values(reset_token)
      User.where(reset_token:).where("reset_expires_at >= ?", Time.current).first
    end
  end

  def enable_reset_password
    self.reset_token = SecureRandom.hex(32)
    self.reset_expires_at = 4.hours.from_now
    save
  end

  def delete_reset_values
    self.reset_token = nil
    self.reset_expires_at = nil
    save
  end

  private

    def downcase_attributes
      self.username = username.downcase
      self.email = email&.downcase
    end
end
