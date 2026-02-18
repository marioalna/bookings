# 12 - Bugs and Tech Debt

## Summary

| ID | Severity | Type | Description |
|----|----------|------|-------------|
| BUG-01 | Critical | Bug | `PasswordsController` uses `find_by_password_reset_token!` not configured in User model |
| BUG-02 | High | Bug | Booking validates `colour` column that doesn't exist in the table |
| BUG-03 | Medium | Bug | Missing `t()` in `PasswordsController` line 31 |
| BUG-04 | Low | Code smell | Double save in admin controllers (create + redundant save) |
| BUG-05 | Low | Dead code | `ResourceChecker` dead branch (where.not excludes user, then checks user) |
| BUG-06 | Medium | Bug | `BookingCustomAttributes` `return` aborts entire each loop |
| BUG-07 | Low | Test bug | Account test checks email validation that doesn't exist |
| BUG-08 | Medium | i18n | `en.yml` contains Spanish text and duplicate keys |
| BUG-09 | Low | i18n | `en.yml` missing `admin.customAttributes` section |
| BUG-10 | Medium | Potential bug | User `attribute :role` may interfere with enum |
| BUG-11 | Medium | Missing config | Missing `dependent: :destroy` on Booking associations |
| BUG-12 | Low | Missing config | Missing foreign keys in schema |
| BUG-13 | Low | Missing handling | `AvailableResources` `.to_date` without rescue |
| BUG-14 | Low | Performance | `CurrentInfo` iterates in Ruby instead of SQL aggregation |
| BUG-15 | Medium | Duplication | Massive duplication CalendarController / BookingsController |

---

## BUG-01: PasswordsController uses `find_by_password_reset_token!`

**Severity:** Critical
**Type:** Bug
**File:** `app/controllers/passwords_controller.rb:29`

### Current Code

```ruby
def set_user_by_token
  @user = User.find_by_password_reset_token!(params[:token])
rescue ActiveSupport::MessageVerifier::InvalidSignature
  redirect_to new_password_path, alert: ('passwords.reset.invalid')
end
```

### Problem

`find_by_password_reset_token!` is a Rails 8 method that works with `generates_token_for :password_reset`. The `User` model does NOT configure this. Instead, it uses a custom system with `reset_token` and `reset_expires_at` columns, and has its own methods: `enable_reset_password`, `validate_reset_values`, `delete_reset_values`.

### Impact

Password reset is broken. `find_by_password_reset_token!` may raise `NoMethodError` or return unexpected results since the token system is not aligned.

### Proposed Fix

Replace with the custom token lookup:

```ruby
def set_user_by_token
  @user = User.validate_reset_values(params[:token])
  redirect_to new_password_path, alert: t('passwords.reset.invalid') unless @user
end
```

---

## BUG-02: Booking validates `colour` column that doesn't exist

**Severity:** High
**Type:** Bug
**File:** `app/models/booking.rb:10,17`

### Current Code

```ruby
normalizes :colour, with: ->(colour) { colour&.downcase }
validates :colour, inclusion: { in: AVAILABLE_COLOURS }, allow_nil: true
```

### Problem

The `bookings` table does not have a `colour` column (see `db/schema.rb`). The `colour` column exists on `schedule_categories`. The validation always passes because `colour` is always `nil`, but the `normalizes` declaration is unnecessary.

### Impact

No runtime error (validation passes with `allow_nil: true`), but dead code that's confusing. If a colour value were somehow set, it would be lost on save since there's no column.

### Proposed Fix

Remove the `normalizes :colour` and `validates :colour` lines from `Booking`, or add a `colour` column to the `bookings` table if the feature is intended.

---

## BUG-03: Missing `t()` in PasswordsController

**Severity:** Medium
**Type:** Bug
**File:** `app/controllers/passwords_controller.rb:31`

### Current Code

```ruby
redirect_to new_password_path, alert: ('passwords.reset.invalid')
```

### Problem

Missing `t()` helper. The raw string `'passwords.reset.invalid'` is displayed to the user instead of the translated message.

### Proposed Fix

```ruby
redirect_to new_password_path, alert: t('passwords.reset.invalid')
```

---

## BUG-04: Double save in admin controllers

**Severity:** Low
**Type:** Code smell
**Files:**
- `app/controllers/admin/users_controller.rb:13-15`
- `app/controllers/admin/resources_controller.rb:13-15`
- `app/controllers/admin/schedule_categories_controller.rb:13-15`
- `app/controllers/admin/custom_attributes_controller.rb:13-15`

### Current Code

```ruby
def create
  @user = Current.account.users.create user_params  # creates AND saves
  if @user.save                                      # saves again (redundant)
    redirect_to admin_users_path, notice: t("admin.users.created")
  else
    render "new", status: :unprocessable_entity
  end
end
```

### Problem

`.create` already saves the record. The subsequent `.save` is redundant. If `.create` fails validation, the record is not persisted, and `.save` will attempt to save again (and fail again).

### Proposed Fix

Use `.new` + `.save` or `.create` + `.persisted?`:

```ruby
def create
  @user = Current.account.users.new(user_params)
  if @user.save
    redirect_to admin_users_path, notice: t("admin.users.created")
  else
    render "new", status: :unprocessable_entity
  end
end
```

---

## BUG-05: ResourceChecker dead branch

**Severity:** Low
**Type:** Dead code
**File:** `app/middleware/bookings/resource_checker.rb:25-33`

### Current Code

```ruby
def validate_booked_on_date
  taken_resource_booking = resource.bookings
    .where(start_on: date)
    .where(schedule_category_id:)
    .where.not(user_id: current_user.id)  # excludes current user
    &.first

  return if taken_resource_booking.blank?

  errors << if taken_resource_booking.user == current_user  # can never be true
    I18n.t('bookings.errors.takenByUser')
  else
    I18n.t('bookings.errors.takenByOtherUser')
  end
end
```

### Problem

The query explicitly excludes the current user with `.where.not(user_id: current_user.id)`, so the result can never have `user == current_user`. The `takenByUser` error message is unreachable.

### Proposed Fix

Either remove the `.where.not` clause to allow both error paths, or simplify to always use `takenByOtherUser`.

---

## BUG-06: BookingCustomAttributes `return` aborts loop

**Severity:** Medium
**Type:** Bug
**File:** `app/middleware/bookings/booking_custom_attributes.rb:13,25`

### Current Code

```ruby
def create
  return if custom_attribute_ids.nil?
  custom_attribute_ids.each do |id|
    return unless valid_id?(id)  # exits entire method, not just iteration
    booking.booking_custom_attributes.create custom_attribute_id: id
  end
end
```

### Problem

`return` inside an `each` block exits the entire method. If any ID fails validation, all subsequent IDs are skipped. This affects both `create` and `update` methods.

### Impact

If a list of custom attribute IDs contains one invalid ID, all IDs after it are silently ignored.

### Proposed Fix

Use `next` instead of `return`:

```ruby
custom_attribute_ids.each do |id|
  next unless valid_id?(id)
  booking.booking_custom_attributes.create custom_attribute_id: id
end
```

Additionally, `valid_id?` uses `.find` which raises `ActiveRecord::RecordNotFound` on missing records, so the method should use `find_by` instead:

```ruby
def valid_id?(id)
  account.custom_attributes.find_by(id: id).present?
end
```

---

## BUG-07: Account test checks non-existent email validation

**Severity:** Low
**Type:** Test bug
**File:** `test/models/account_test.rb:10-14`

### Current Code

```ruby
test 'validation email' do
  account = Account.new name: 'test name'
  assert_not account.valid?
end
```

### Problem

This test expects `Account` to be invalid without an email. However, `Account` only validates `name` presence. The `attr_accessor :email` is a virtual attribute with no validation. This test passes because `account.valid?` is `true` (name is present), so `assert_not true` fails.

**Wait** — actually, if `name: 'test name'` is present and that's the only validation, then `account.valid?` returns `true`, and `assert_not true` evaluates to `false`, which means the test **fails**. This is a broken test.

### Proposed Fix

Remove this test, or add email validation to `Account` if it's needed.

---

## BUG-08: `en.yml` contains Spanish text and duplicate keys

**Severity:** Medium
**Type:** i18n
**File:** `config/locales/en.yml:51-56`

### Current Code

```yaml
en:
  bookings:
    errors:
      noResourcesAvailable: "There are no resources available for this date and schedule"
      invalidDate: "You have to choose a future date"
      invalidSchedule: "Invalid schedule"
      noResourcesAvailable: "No hay recursos disponibles para esta fecha y horario."
      takenByUser: "Ya tienes una reservado este recurso para esta fecha y horario."
      takenByOtherUser: "Otro usuario ya tiene reservado este recurso para esta fecha y horario."
```

### Problem

1. `noResourcesAvailable` is duplicated — YAML uses the last value, so the Spanish text overrides the English
2. `takenByUser` and `takenByOtherUser` are in Spanish instead of English

### Proposed Fix

Remove duplicate key and translate Spanish strings to English.

---

## BUG-09: `en.yml` missing `admin.customAttributes` section

**Severity:** Low
**Type:** i18n
**File:** `config/locales/en.yml`

### Problem

The `es.yml` has a complete `admin.customAttributes` section. The `en.yml` is missing it entirely. Users with English locale will see raw key paths instead of translated strings on the custom attributes admin pages.

### Proposed Fix

Add the `admin.customAttributes` section to `en.yml` with English translations.

---

## BUG-10: User `attribute :role` may interfere with enum

**Severity:** Medium
**Type:** Potential bug
**File:** `app/models/user.rb:4`

### Current Code

```ruby
class User < ApplicationRecord
  has_secure_password
  attribute :role       # line 4
  # ...
  enum :role, { regular: 0, admin: 9 }
end
```

### Problem

`attribute :role` redeclares the `role` attribute without a type, which may reset the type information before the `enum` declaration processes it. This could interfere with how the enum casts integer values to strings.

### Impact

May work correctly in practice, but is unusual and fragile. If it's intended to set a default, it should be `attribute :role, :integer, default: 0`.

### Proposed Fix

Remove `attribute :role` or change to `attribute :role, :integer, default: 0`.

---

## BUG-11: Missing `dependent: :destroy` on Booking associations

**Severity:** Medium
**Type:** Missing config
**File:** `app/models/booking.rb:5-8`

### Current Code

```ruby
has_many :resource_bookings
has_many :resources, through: :resource_bookings
has_many :booking_custom_attributes
has_many :custom_attributes, through: :booking_custom_attributes
```

### Problem

No `dependent: :destroy` on `resource_bookings` or `booking_custom_attributes`. When a booking is deleted, its join records are orphaned in the database.

### Proposed Fix

```ruby
has_many :resource_bookings, dependent: :destroy
has_many :booking_custom_attributes, dependent: :destroy
```

---

## BUG-12: Missing foreign keys in schema

**Severity:** Low
**Type:** Missing config
**File:** `db/schema.rb`

### Problem

Only 3 explicit foreign keys exist (Active Storage and sessions). All other relationships rely on application-level `belongs_to` validation. This means:

- Orphaned records can exist if records are deleted via raw SQL
- No database-level referential integrity for most tables

### Tables Missing Foreign Keys

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

### Proposed Fix

Create a migration adding foreign keys for all relationships.

---

## BUG-13: `AvailableResources` `.to_date` without rescue

**Severity:** Low
**Type:** Missing handling
**File:** `app/middleware/bookings/available_resources.rb:37`

### Current Code

```ruby
def validate_params
  schedule_category = account.schedule_categories.find_by id: schedule_category_id

  if date.nil?
    errors << I18n.t("bookings.errors.invalidDate")
  elsif date.to_date < Date.today
    errors << I18n.t("bookings.errors.invalidDate")
  end

  errors << I18n.t("bookings.errors.invalidSchedule") unless schedule_category
end
```

### Problem

`date.to_date` on line 37 can raise `Date::Error` or `NoMethodError` if `date` is a non-nil but unparseable string. The `nil?` check on line 35 only guards against `nil`, not invalid strings.

### Impact

Low — the controller typically passes validated date strings, but edge cases could crash the request.

### Proposed Fix

Wrap in a rescue or validate the date format before calling `.to_date`.

---

## BUG-14: `CurrentInfo` iterates in Ruby instead of SQL

**Severity:** Low
**Type:** Performance
**File:** `app/middleware/bookings/current_info.rb:15-19`

### Current Code

```ruby
bookings = account.bookings.where(start_on:, schedule_category_id:)
bookings.each do |booking|
  @num_bookings += 1
  @participants += booking.participants
end
```

### Problem

Loads all matching bookings into memory and iterates in Ruby to count and sum. This should be a single SQL query.

### Proposed Fix

```ruby
count, total = account.bookings
  .where(start_on:, schedule_category_id:)
  .pick(Arel.sql("COUNT(*), COALESCE(SUM(participants), 0)"))

@num_bookings = count
@participants = total
```

---

## BUG-15: Massive duplication CalendarController / BookingsController

**Severity:** Medium
**Type:** Duplication
**Files:**
- `app/controllers/calendar_controller.rb`
- `app/controllers/bookings_controller.rb`

### Problem

9 private methods are duplicated between the two controllers:

1. `booking_params`
2. `find_schedule_categories`
3. `find_resources`
4. `custom_attributes`
5. `start_on`
6. `schedule_category_id`
7. `available_resources`
8. `current_info`
9. `booking_date`

### Proposed Fix

Extract shared methods to a concern:

```ruby
# app/controllers/concerns/booking_setup.rb
module BookingSetup
  extend ActiveSupport::Concern

  private
    def booking_params
      params.require(:booking).permit(:start_on, :schedule_category_id, :participants,
                                       resource_bookings_attributes: %i[resource_id])
    end

    def find_schedule_categories
      @schedule_categories = Current.account.schedule_categories.pluck(:id, :name)
    end

    # ... remaining shared methods
end
```
