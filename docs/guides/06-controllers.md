# 06 - Controllers

## ApplicationController

**File:** `app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  include Authentication
  before_action :set_language

  def set_language
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
```

- Includes `Authentication` concern (requires login for all actions by default)
- Sets locale from `params[:locale]`, falling back to `:es` (Spanish)

---

## CalendarController

**File:** `app/controllers/calendar_controller.rb`

| Action | Method | Purpose |
|--------|--------|---------|
| `index` | GET | Displays monthly calendar grid |
| `new` | GET | Booking form (modal via Turbo Frame) |
| `create` | POST | Creates booking, responds with Turbo Stream |
| `check` | POST | Checks availability, responds with Turbo Stream |

### Before Actions

```ruby
before_action :find_date
before_action :find_schedule_categories, only: %i[new create]
before_action :find_resources, only: %i[new create]
```

### Key Logic

- `index`: Calls `Bookings::Calendar.call` to build monthly grid, slices into weeks
- `new`: Builds a new booking for the current user, loads available resources, current info, and custom attributes
- `create`: Creates booking, on success builds Turbo Stream update for the calendar day cell. On failure re-renders form with errors
- `check`: Called via Stimulus when user changes date/schedule, returns Turbo Stream with updated resources/info

### Private Methods

Most private methods are **duplicated** in `BookingsController`. See [Duplication Analysis](#calendarcontroller--bookingscontroller-duplication) below.

---

## BookingsController

**File:** `app/controllers/bookings_controller.rb`

| Action | Method | Purpose |
|--------|--------|---------|
| `index` | GET | Lists user's bookings (with filters) |
| `new` | GET | Booking form (full page) |
| `create` | POST | Creates booking, redirects on success |
| `edit` | GET | Edit booking form |
| `update` | PATCH | Updates booking |
| `destroy` | DELETE | Deletes booking |
| `check` | POST | Checks availability (Turbo Stream) |

### Before Actions

```ruby
before_action :find_booking, only: %i[edit update destroy]
before_action :find_schedule_categories, only: %i[new check create edit update]
before_action :find_resources, only: %i[new create edit update]
before_action :find_date, only: %i[index]
before_action :find_bookings, only: %i[index]
```

### Key Differences from CalendarController

- Has full CRUD (edit, update, destroy)
- `create` redirects on success instead of returning Turbo Stream
- `index` uses `Bookings::Finder` for filtered listing
- `find_booking` scopes by user role (admins can access any booking)

### Authorization in `find_booking`

```ruby
def find_booking
  @booking = if Current.user.admin?
    Current.account.bookings.find params[:id]
  else
    Current.user.bookings.find params[:id]
  end
end
```

---

## CalendarEventsController

**File:** `app/controllers/calendar_events_controller.rb`

| Action | Method | Purpose |
|--------|--------|---------|
| `index` | GET | Shows bookings for a specific day |

```ruby
class CalendarEventsController < ApplicationController
  def index
    @bookings = Current.account.bookings.for_today(date)
  end

  private
    def date
      params[:date] || Date.current.to_s
    end
end
```

Simple controller that loads all bookings for a given date.

---

## SessionsController

**File:** `app/controllers/sessions_controller.rb`

| Action | Method | Purpose |
|--------|--------|---------|
| `new` | GET | Login form |
| `create` | POST | Authenticate and create session |
| `destroy` | DELETE | Logout |

```ruby
allow_unauthenticated_access only: %i[new create]
rate_limit to: 10, within: 3.minutes, only: :create
```

- Login uses `User.authenticate_by(email:, password:)`
- Rate limited to 10 attempts per 3 minutes

---

## PasswordsController

**File:** `app/controllers/passwords_controller.rb`

| Action | Method | Purpose |
|--------|--------|---------|
| `new` | GET | Password reset request form |
| `create` | POST | Send reset email |
| `edit` | GET | Password reset form (via token) |
| `update` | PATCH | Update password |

```ruby
allow_unauthenticated_access
before_action :set_user_by_token, only: %i[edit update]
```

**Known bugs:**
- `set_user_by_token` calls `User.find_by_password_reset_token!` which may not work with the custom token system (BUG-01)
- Line 31 missing `t()` call: `alert: ('passwords.reset.invalid')` (BUG-03)

---

## AdminController (Base)

**File:** `app/controllers/admin_controller.rb`

```ruby
class AdminController < ApplicationController
  before_action :is_admin

  private
    def is_admin
      return if Current.user.role == User::ADMIN
      redirect_to calendar_index_path
      @valid = false
    end
end
```

Base controller for all admin controllers. Redirects non-admin users to the calendar.

---

## Admin::UsersController

**File:** `app/controllers/admin/users_controller.rb`

Full CRUD for users scoped to `Current.account.users`.

**Permitted params:** `:name, :username, :email, :password, :active`

**Bug:** `create` action calls `Current.account.users.create` then `.save` (double save). See BUG-04.

---

## Admin::ResourcesController

**File:** `app/controllers/admin/resources_controller.rb`

Full CRUD for resources scoped to `Current.account.resources`.

**Permitted params:** `:name, :max_capacity, :photo`

**Bug:** Same double save pattern in `create` action (BUG-04).

---

## Admin::ScheduleCategoriesController

**File:** `app/controllers/admin/schedule_categories_controller.rb`

Full CRUD for schedule categories scoped to `Current.account.schedule_categories`.

**Permitted params:** `:name, :icon, :colour`

**Bug:** Same double save pattern in `create` action (BUG-04).

---

## Admin::CustomAttributesController

**File:** `app/controllers/admin/custom_attributes_controller.rb`

Full CRUD for custom attributes scoped to `Current.account.custom_attributes`.

**Permitted params:** `:name, :block_on_schedule`

**Bug:** Same double save pattern in `create` action (BUG-04).

---

## CalendarController / BookingsController Duplication

The following private methods are **identical** (or nearly identical) in both controllers:

| Method | CalendarController | BookingsController |
|--------|-------------------|-------------------|
| `booking_params` | line 43 | line 65 |
| `find_schedule_categories` | line 59 | line 69 |
| `find_resources` | line 63 | line 73 |
| `custom_attributes` | line 55 | line 86 |
| `start_on` | line 68 | line 90 |
| `schedule_category_id` | line 74 | line 96 |
| `available_resources` | line 80 | line 102 |
| `current_info` | line 84 | line 106 |
| `booking_date` | line 99 | line 123 |

These 9 methods could be extracted to a shared concern. See [12-bugs-and-tech-debt.md](12-bugs-and-tech-debt.md) BUG-15.

### Admin CRUD Pattern

All 4 admin controllers follow an identical pattern:

```ruby
class Admin::XxxController < AdminController
  before_action :find_xxx, only: %i[edit update destroy]

  def index
    @xxxs = Current.account.xxxs
  end

  def new
    @xxx = Current.account.xxxs.new
  end

  def create
    @xxx = Current.account.xxxs.create xxx_params  # creates AND saves
    if @xxx.save                                    # redundant save
      redirect_to admin_xxxs_path, notice: t("admin.xxx.created")
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @xxx.update(xxx_params)
      redirect_to admin_xxxs_path, notice: t("admin.xxx.updated")
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    @xxx.destroy
    redirect_to admin_xxxs_path, notice: t("admin.xxx.deleted")
  end
end
```
