# 10 - Testing

## Framework

- **Test framework:** Minitest (Rails default)
- **Parallelization:** Enabled with `parallelize(workers: :number_of_processors)`
- **Fixtures:** All fixtures loaded automatically via `fixtures :all`
- **System tests:** Capybara + Selenium WebDriver available (gems installed) but no system tests written

**File:** `test/test_helper.rb`

```ruby
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    def log_in_admin
      post session_path, params: { email: 'admin2@test.com', password: 'testme' }
    end

    def log_in_user
      post session_path, params: { email: 'regular2@test.com', password: 'testme' }
    end
  end
end
```

## Authentication Helpers

| Helper | Email | Password | Role |
|--------|-------|----------|------|
| `log_in_admin` | `admin2@test.com` | `testme` | admin (9) |
| `log_in_user` | `regular2@test.com` | `testme` | regular (0) |

These correspond to the fixtures in `test/fixtures/users.yml`.

## Fixtures

### `test/fixtures/accounts.yml`

```yaml
account:
  name: "Account test"
```

### `test/fixtures/users.yml`

```yaml
regular:
  account: account
  name: "regular name2"
  username: "regular2user"
  email: "regular2@test.com"
  role: 0
  password_digest: <%= BCrypt::Password.create('testme', cost: 5) %>

admin:
  account: account
  name: "admin name2"
  username: "admin2user"
  email: "admin2@test.com"
  role: 9
  password_digest: <%= BCrypt::Password.create('testme', cost: 5) %>
```

### `test/fixtures/schedule_categories.yml`

```yaml
schedule_category:
  account: account
  name: "mananas"
  colour: "red"

schedule_category2:
  account: account
  name: "tardes"
  colour: "blue"
```

### `test/fixtures/bookings.yml`

5 bookings spread across the current month using dynamic dates:

| Fixture | User | Schedule | Date | Participants |
|---------|------|----------|------|-------------|
| `booking1_sc1` | admin | schedule_category | Beginning of month | 9 |
| `booking5_sc1` | regular | schedule_category | Beginning of month | 13 |
| `booking2_sc2` | regular | schedule_category2 | +4 days | 7 |
| `booking3_sc2` | admin | schedule_category2 | +14 days | 27 |
| `booking4_sc1` | admin | schedule_category | +4 days | 11 |

### `test/fixtures/resources.yml`

```yaml
resource:
  account: account
  name: "resource name"
  max_capacity: 12

resource2:
  account: account
  name: "resource name2"
  max_capacity: 8
```

### `test/fixtures/resource_bookings.yml`

```yaml
rb_1:
  booking: booking1_sc1
  resource: resource

rb_2:
  booking: booking5_sc1
  resource: resource2
```

### `test/fixtures/custom_attributes.yml`

```yaml
custom_attribute:
  account: account
  name: "Horno"
  block_on_schedule: true
```

### `test/fixtures/booking_custom_attributes.yml`

Empty file (no fixture data).

## Tests by Type

### Model Tests (`test/models/`)

| File | Tests | Notes |
|------|-------|-------|
| `account_test.rb` | 2 | Tests name validation; also tests email validation which doesn't exist on Account (BUG-07) |
| `user_test.rb` | Present | Tests user validations |
| `booking_test.rb` | **0** | Entirely commented out placeholder (BUG) |
| `resource_test.rb` | Present | Tests resource validations |
| `resource_booking_test.rb` | Present | Tests join model |
| `schedule_category_test.rb` | Present | Tests schedule category validations |
| `custom_attribute_test.rb` | Present | Tests custom attribute validations |
| `booking_custom_attribute_test.rb` | Present | Tests join model |

### Integration Tests (`test/integration/`)

| File | Tests | Notes |
|------|-------|-------|
| `calendar_controller_test.rb` | Present | Tests calendar index, new, create, check |
| `bookings_controller_test.rb` | Present | Tests bookings CRUD |
| `calendar_events_controller_test.rb` | Present | Tests calendar events index |
| `admin/users_controller_test.rb` | Present | Tests admin user management |
| `admin/resources_controller_test.rb` | Present | Tests admin resource management |
| `admin/schedule_categories_controller_test.rb` | Present | Tests admin schedule categories |

### Middleware Tests (`test/middleware/bookings/`)

| File | Tests | Notes |
|------|-------|-------|
| `calendar_test.rb` | Present | Tests calendar building logic |
| `finder_test.rb` | Present | Tests booking filtering |
| `available_resources_test.rb` | Present | Tests resource availability |
| `resource_checker_test.rb` | Present | Tests resource validation |
| `current_info_test.rb` | Present | Tests booking stats |
| `custom_attributes_test.rb` | Present | Tests custom attribute availability |

### Mailer Tests

| File | Tests | Notes |
|------|-------|-------|
| `passwords_mailer_test.rb` | Present | Tests password reset mailer |

## Coverage Gaps

| Gap | Severity | Description |
|-----|----------|-------------|
| `booking_test.rb` is empty | High | The most important model has no tests |
| No system tests | Medium | Capybara/Selenium installed but no tests written |
| No tests for `BookingCustomAttributes` service | Medium | `app/middleware/bookings/booking_custom_attributes.rb` untested |
| No tests for `admin/custom_attributes_controller` | Low | Admin custom attributes controller untested |
| No tests for `sessions_controller` | Medium | Login/logout flow untested |
| No tests for `passwords_controller` | Medium | Password reset flow untested |
| `account_test.rb` tests non-existent email validation | Low | See BUG-07 |

## Running Tests

```bash
# All tests
bin/rails test

# All tests including system tests
bin/rails test test:system

# Single file
bin/rails test test/models/booking_test.rb

# Single test at line
bin/rails test test/models/booking_test.rb:42

# Middleware tests only
bin/rails test test/middleware/

# Integration tests only
bin/rails test test/integration/

# Prepare test database
bin/rails db:test:prepare
```
