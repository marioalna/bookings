# 05 - Service Layer

The service layer lives in `app/middleware/bookings/`. Despite the directory name, these are **not Rack middleware** — they are plain Ruby service objects that encapsulate booking business logic.

## 1. Bookings::Calendar

**File:** `app/middleware/bookings/calendar.rb`

**Purpose:** Builds a monthly calendar grid with aggregated booking data for each day.

### Interface

```ruby
# Class-level shortcut
Bookings::Calendar.call(account, date_string)

# Or instance
Bookings::Calendar.new(account, "2025-06").call
```

**Input:**
- `account` — an `Account` instance (for scoping bookings)
- `date` — a string in `"YYYY-MM"` format

**Output:** An array of hashes, one per day in the calendar grid (Monday–Sunday weeks):

```ruby
[
  { day: Date, bookings: [<aggregated booking records>] },
  { day: Date, bookings: [] },
  ...
]
```

### How It Works

1. Parses the date string to find the month boundaries
2. Extends to full weeks: `first_day = start_date.beginning_of_month.beginning_of_week` and `last_day = start_date.end_of_month.end_of_week`
3. Queries all bookings in the range, grouped by `start_on` and `schedule_category_id`
4. For each day in the range, selects matching bookings from the result set

### SQL Query

```sql
SELECT bookings.start_on,
       SUM(bookings.participants) as participants,
       schedule_categories.name as schedule_category_name,
       schedule_categories.colour as schedule_category_colour
FROM bookings
INNER JOIN schedule_categories ON ...
WHERE bookings.start_on BETWEEN first_day AND last_day
GROUP BY bookings.start_on, bookings.schedule_category_id
```

### Performance Note

The `results` method iterates all days and filters bookings with Ruby `.select`, which is O(days * bookings). For a typical month (35-42 days), this is fast enough, but could be optimized with a hash lookup.

### Usage

```ruby
# CalendarController#index (line 7)
monthly_info = Bookings::Calendar.call Current.account, @date.strftime("%Y-%m")
@weeks = monthly_info.each_slice(7)
```

---

## 2. Bookings::Finder

**File:** `app/middleware/bookings/finder.rb`

**Purpose:** Filters bookings by optional user or resource within a date range.

### Interface

```ruby
Bookings::Finder.new(account, params, date_range).call
```

**Input:**
- `account` — an `Account` instance
- `params` — request params (may contain `user_id` or `resource_id`)
- `dates_range` — a `Date` range (e.g., `start_date..end_date`)

**Output:** An ActiveRecord relation of bookings, ordered by `start_on, schedule_category_id`.

### Logic

```ruby
if user_id.present?
  # Filter by user
  account.bookings.where(start_on: dates_range, user_id: params[:user_id])
elsif resource_id.present?
  # Filter by resource (through join)
  account.bookings.joins(:resources).where(start_on: dates_range, resources: { id: resource_id })
else
  # All bookings in range
  account.bookings.where(start_on: dates_range)
end
```

### Security

The `user_id` and `resource_id` methods verify the IDs belong to the account before using them:

```ruby
def user_id
  account.users.find_by(id: params[:user_id])&.id
end
```

### Usage

```ruby
# BookingsController#find_bookings (line 115)
@bookings = Bookings::Finder.new(Current.account, params, @start_date..@end_date).call
```

---

## 3. Bookings::AvailableResources

**File:** `app/middleware/bookings/available_resources.rb`

**Purpose:** Determines which resources are available for a given user, date, and schedule category.

### Interface

```ruby
Bookings::AvailableResources.new(current_user, date, schedule_category_id).call
```

**Input:**
- `current_user` — the `User` making the booking
- `date` — the booking date (string or Date)
- `schedule_category_id` — the selected schedule category

**Output:** A tuple `[available_resources, errors]`:
- `available_resources` — array of `Resource` objects that are available
- `errors` — array of error message strings

### Logic

1. **Validate params:** checks date is not in the past and schedule category exists
2. **Check each resource:** iterates all account resources, calling `ResourceChecker` for each
3. If `ResourceChecker` returns no errors, the resource is available
4. If no resources are available, adds a "no resources available" error

### Bug: `.to_date` Without Rescue

Line 37 calls `date.to_date` without error handling. A `nil?` check guards against nil, but if `date` is an invalid non-nil string, this will raise `Date::Error`. See [12-bugs-and-tech-debt.md](12-bugs-and-tech-debt.md) BUG-13.

### Usage

```ruby
# CalendarController (line 81) and BookingsController (line 103)
@available_resources, @errors = Bookings::AvailableResources.new(Current.user, start_on, schedule_category_id).call
```

---

## 4. Bookings::ResourceChecker

**File:** `app/middleware/bookings/resource_checker.rb`

**Purpose:** Validates whether a specific resource is available for a booking.

### Interface

```ruby
Bookings::ResourceChecker.new(current_user, resource_id:, date:, schedule_category_id:, capacity: nil).call
```

**Input:**
- `current_user` — the `User` making the booking
- `resource_id:` — the resource to check
- `date:` — the booking date
- `schedule_category_id:` — the schedule category
- `capacity:` — optional, number of participants to validate against max_capacity

**Output:** An array of error strings. Empty array means the resource is available.

### Logic

#### `validate_booked_on_date`

```ruby
taken_resource_booking = resource.bookings
  .where(start_on: date)
  .where(schedule_category_id:)
  .where.not(user_id: current_user.id)
  &.first
```

Checks if another user has already booked this resource for the same date and schedule.

**Bug (dead branch):** The query excludes the current user with `.where.not(user_id: current_user.id)`, but then line 29 checks `if taken_resource_booking.user == current_user` which can never be true. See [12-bugs-and-tech-debt.md](12-bugs-and-tech-debt.md) BUG-05.

#### `validate_capacity`

```ruby
return if capacity.nil? || resource.max_capacity >= capacity
errors << I18n.t('bookings.errors.invalidCapacity')
```

Checks if the resource has enough capacity. Note: `capacity` is only passed when explicitly provided (currently not used by `AvailableResources`).

---

## 5. Bookings::CurrentInfo

**File:** `app/middleware/bookings/current_info.rb`

**Purpose:** Returns booking statistics for a specific date and schedule category.

### Interface

```ruby
Bookings::CurrentInfo.new(account, start_on, schedule_category_id).call
```

**Input:**
- `account` — an `Account` instance
- `start_on` — the date
- `schedule_category_id` — the schedule category

**Output:** A hash:

```ruby
{ num_bookings: Integer, participants: Integer, schedule_name: String }
```

### Logic

```ruby
bookings = account.bookings.where(start_on:, schedule_category_id:)
bookings.each do |booking|
  @num_bookings += 1
  @participants += booking.participants
end
```

### Performance Note

This loads all matching bookings into memory and iterates in Ruby to count and sum. Could be replaced with a single SQL query:

```ruby
account.bookings
  .where(start_on:, schedule_category_id:)
  .pick(Arel.sql("COUNT(*), SUM(participants)"))
```

See [12-bugs-and-tech-debt.md](12-bugs-and-tech-debt.md) BUG-14.

### Usage

```ruby
# CalendarController (line 85) and BookingsController (line 107)
info = Bookings::CurrentInfo.new(Current.account, start_on, schedule_category_id).call
@num_bookings = info[:num_bookings]
@participants = info[:participants]
@schedule_name = info[:schedule_name]
```

---

## 6. Bookings::CustomAttributes

**File:** `app/middleware/bookings/custom_attributes.rb`

**Purpose:** Determines which custom attributes are available or blocked for a booking.

### Interface

```ruby
Bookings::CustomAttributes.new(user, date, schedule_category_id).call
```

**Input:**
- `user` — the `User` making the booking
- `date` — the booking date
- `schedule_category_id` — the schedule category

**Output:** A hash:

```ruby
{ not_available: [CustomAttribute, ...], available: [CustomAttribute, ...] }
```

### Logic

1. Loads all custom attributes for the user's account
2. Filters to only those with `block_on_schedule: true`
3. For each blocking attribute, checks if another user (not the current user) has already selected it for the same date and schedule
4. If taken by another user -> `not_available`, otherwise -> `available`

### `invalid_attribute?` Check

```ruby
def invalid_attribute?(custom_attribute)
  bookings_for_today
    .includes(:booking_custom_attributes)
    .where(booking_custom_attributes: { custom_attribute_id: custom_attribute.id })
    .where.not(user_id: user.id)
    .present?
end
```

This checks if any booking (by another user) for the same date and schedule already uses this custom attribute.

**Note:** Custom attributes with `block_on_schedule: false` are not included in either list.

---

## 7. Bookings::BookingCustomAttributes

**File:** `app/middleware/bookings/booking_custom_attributes.rb`

**Purpose:** Manages the join records between a booking and its custom attributes.

### Interface

```ruby
service = Bookings::BookingCustomAttributes.new(booking, custom_attribute_ids, account)
service.create  # for new bookings
service.update  # for existing bookings
```

**Input:**
- `booking` — a `Booking` instance
- `custom_attribute_ids` — array of custom attribute IDs (from form params)
- `account` — the `Account` (for validating IDs belong to the account)

### `create` Method

```ruby
def create
  return if custom_attribute_ids.nil?
  custom_attribute_ids.each do |id|
    return unless valid_id?(id)
    booking.booking_custom_attributes.create custom_attribute_id: id
  end
end
```

### `update` Method

```ruby
def update
  booking.booking_custom_attributes.delete_all
  return if custom_attribute_ids.nil?
  custom_attribute_ids.each do |id|
    return unless valid_id?(id)
    booking.booking_custom_attributes.create custom_attribute_id: id
  end
end
```

Deletes all existing associations and re-creates them.

### Bug: `return` Aborts Loop

Both `create` and `update` use `return unless valid_id?(id)` inside the `each` loop. If any ID fails validation, the `return` statement exits the **entire method**, not just the current iteration. This means subsequent valid IDs are never processed. Should use `next` instead. See [12-bugs-and-tech-debt.md](12-bugs-and-tech-debt.md) BUG-06.

### `valid_id?`

```ruby
def valid_id?(id)
  custom_attribute = account.custom_attributes.find id
  custom_attribute.present?
end
```

Uses `find` which raises `ActiveRecord::RecordNotFound` if the ID doesn't exist, making the `.present?` check redundant. The exception is not rescued, so an invalid ID will crash the request.

### Usage

```ruby
# CalendarController#create (line 22) and BookingsController#create (line 23)
Bookings::BookingCustomAttributes.new(@booking, params[:custom_attribute_ids], Current.account).create
```
