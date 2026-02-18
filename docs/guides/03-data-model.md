# 03 - Data Model

## Entity Relationship Diagram

```
Account (1) ───< (many) Users
Account (1) ───< (many) Resources
Account (1) ───< (many) ScheduleCategories
Account (1) ───< (many) CustomAttributes
Account (1) ───< (many) Bookings  (through Users)

User (1) ───< (many) Bookings
User (1) ───< (many) Sessions

Booking (many) >─── (1) User
Booking (many) >─── (1) ScheduleCategory
Booking (many) ───< ResourceBookings >─── (many) Resources
Booking (many) ───< BookingCustomAttributes >─── (many) CustomAttributes

Resource has_one_attached :photo (Active Storage)
```

## Schema (version: `2025_05_19_112359`)

### `accounts`

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer (PK) | auto |
| name | string | |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

No indexes beyond primary key. No foreign keys.

---

### `users`

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer (PK) | auto |
| email | string | NOT NULL |
| password_digest | string | NOT NULL |
| account_id | bigint | |
| name | string | |
| username | string | |
| reset_token | string | |
| role | integer | DEFAULT 0 |
| reset_expires_at | datetime | |
| active | boolean | DEFAULT true |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

**Indexes:**
- `index_users_on_account_id_and_email` on `[account_id, email]` (UNIQUE)
- `index_users_on_email` on `email` (UNIQUE)

---

### `sessions`

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer (PK) | auto |
| user_id | integer | NOT NULL |
| ip_address | string | |
| user_agent | string | |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

**Indexes:** `index_sessions_on_user_id`
**Foreign keys:** `user_id` references `users`

---

### `bookings`

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer (PK) | auto |
| user_id | integer | |
| schedule_category_id | integer | |
| start_on | date | NOT NULL |
| end_on | date | |
| participants | integer | NOT NULL, DEFAULT 0 |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

**Indexes:**
- `index_bookings_on_schedule_category_id`
- `index_bookings_on_user_id`
- `idx_on_user_id_schedule_category_id_start_on_0264bf7367` on `[user_id, schedule_category_id, start_on]` (UNIQUE)

**Note:** No `colour` column exists in this table, despite the model validating it. See [12-bugs-and-tech-debt.md](12-bugs-and-tech-debt.md) BUG-02.

---

### `schedule_categories`

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer (PK) | auto |
| account_id | integer | |
| name | string | NOT NULL |
| icon | string | |
| colour | string | |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

**Indexes:** `index_schedule_categories_on_account_id`

---

### `resources`

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer (PK) | auto |
| account_id | integer | |
| name | string | NOT NULL |
| max_capacity | integer | DEFAULT 0 |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

**Indexes:** `index_resources_on_account_id`

---

### `resource_bookings` (join table)

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer (PK) | auto |
| resource_id | integer | |
| booking_id | integer | |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

**Indexes:**
- `index_resource_bookings_on_booking_id`
- `index_resource_bookings_on_resource_id`
- `index_resource_bookings_on_resource_id_and_booking_id` on `[resource_id, booking_id]` (UNIQUE)

---

### `custom_attributes`

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer (PK) | auto |
| account_id | integer | |
| name | string | NOT NULL |
| block_on_schedule | boolean | DEFAULT false |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

**Indexes:** `index_custom_attributes_on_account_id`

---

### `booking_custom_attributes` (join table)

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer (PK) | auto |
| booking_id | integer | |
| custom_attribute_id | integer | |
| created_at | datetime | NOT NULL |
| updated_at | datetime | NOT NULL |

**Indexes:**
- `index_booking_custom_attributes_on_booking_id`
- `index_booking_custom_attributes_on_custom_attribute_id`

---

## Models

### Account (`app/models/account.rb`)

```ruby
class Account < ApplicationRecord
  attr_accessor :email  # virtual attribute for registration

  has_many :users, dependent: :destroy
  has_many :custom_attributes, dependent: :destroy
  has_many :resources, dependent: :destroy
  has_many :schedule_categories, dependent: :destroy
  has_many :bookings, through: :users

  validates :name, presence: true
end
```

- `attr_accessor :email` is a virtual attribute used during account registration to create the first user.
- `has_many :bookings, through: :users` enables `Current.account.bookings` to query all bookings across all users.

### User (`app/models/user.rb`)

```ruby
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
                       format: { with: /\A[\p{L}\p{N}]+\z/, message: :invalid }
  validates :email, format: { with: /\A([\w+-].?)+@[a-z\d-]+(\.[a-z]+)*\.[a-z]+\z/i, message: :invalid }

  enum :role, { regular: 0, admin: 9 }
  before_save :downcase_attributes
end
```

**Key methods:**
- `validate_reset_values(reset_token)` (class method) - finds user by reset token that hasn't expired
- `enable_reset_password` - generates hex token, sets 4-hour expiry
- `delete_reset_values` - clears reset token and expiry

**Note:** `attribute :role` redeclares the role attribute before the enum. See [12-bugs-and-tech-debt.md](12-bugs-and-tech-debt.md) BUG-10.

### Booking (`app/models/booking.rb`)

```ruby
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
  validates :start_on, comparison: { greater_than_or_equal_to: Date.current },
            unless: :current_user_is_admin?
  validates :participants, comparison: { greater_than_or_equal_to: 0 }
  validates_uniqueness_of :user_id, scope: [:schedule_category_id, :start_on],
            message: I18n.t('bookings.errors.userTaken')
  validates :colour, inclusion: { in: AVAILABLE_COLOURS }, allow_nil: true

  accepts_nested_attributes_for :resource_bookings, allow_destroy: true, reject_if: :all_blank

  scope :for_today, ->(date) { joins(:schedule_category).where(start_on: date) }
end
```

**Key behavior:**
- `before_create :assign_end_on` sets `end_on = start_on` if blank
- Admins can create bookings in the past (bypasses date validation)
- A user can only have one booking per schedule category per date (unique index + model validation)

### Other Models

| Model | File | Key Details |
|-------|------|-------------|
| `Current` | `app/models/current.rb` | `ActiveSupport::CurrentAttributes`, sets account from session |
| `Resource` | `app/models/resource.rb` | `has_one_attached :photo`, validates name |
| `ScheduleCategory` | `app/models/schedule_category.rb` | Validates name, colour inclusion |
| `CustomAttribute` | `app/models/custom_attribute.rb` | `block_on_schedule` boolean flag |
| `ResourceBooking` | `app/models/resource_booking.rb` | Join model, no validations |
| `BookingCustomAttribute` | `app/models/booking_custom_attribute.rb` | Join model, no validations |
| `Session` | `app/models/session.rb` | `belongs_to :user`, no validations |

## AVAILABLE_COLOURS Constant

Defined in `config/initializers/sociedad.rb`:

```ruby
AVAILABLE_COLOURS = %w[red green yellow blue indigo purple pink orange teal cyan
                       gray amber lime emerald rose sky violet fuchsia slate].freeze
```

Used by `Booking` and `ScheduleCategory` models for colour validation.

## Missing Foreign Keys

Only 3 explicit database foreign keys exist:
1. `active_storage_attachments.blob_id` -> `active_storage_blobs`
2. `active_storage_variant_records.blob_id` -> `active_storage_blobs`
3. `sessions.user_id` -> `users`

The following foreign keys are enforced only at the application level (via `belongs_to`):
- `bookings.user_id` -> `users`
- `bookings.schedule_category_id` -> `schedule_categories`
- `resources.account_id` -> `accounts`
- `schedule_categories.account_id` -> `accounts`
- `custom_attributes.account_id` -> `accounts`
- `users.account_id` -> `accounts`
- `resource_bookings.resource_id` -> `resources`
- `resource_bookings.booking_id` -> `bookings`
- `booking_custom_attributes.booking_id` -> `bookings`
- `booking_custom_attributes.custom_attribute_id` -> `custom_attributes`
