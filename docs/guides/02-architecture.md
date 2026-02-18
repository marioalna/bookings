# 02 - Architecture

## Layer Diagram

```
Browser
  │
  ├── Turbo Drive (full page navigation)
  ├── Turbo Frames (modal dialogs)
  └── Turbo Streams (partial updates via check/create)
  │
  ▼
Routes (config/routes.rb)
  │
  ▼
Controllers
  ├── ApplicationController (Authentication, set_language)
  │     ├── CalendarController
  │     ├── BookingsController
  │     ├── CalendarEventsController
  │     ├── SessionsController
  │     └── PasswordsController
  │
  └── AdminController (inherits ApplicationController + admin check)
        ├── Admin::UsersController
        ├── Admin::ResourcesController
        ├── Admin::ScheduleCategoriesController
        └── Admin::CustomAttributesController
  │
  ▼
Service Layer (app/middleware/bookings/)
  ├── Bookings::Calendar
  ├── Bookings::Finder
  ├── Bookings::AvailableResources
  ├── Bookings::ResourceChecker
  ├── Bookings::CurrentInfo
  ├── Bookings::CustomAttributes
  └── Bookings::BookingCustomAttributes
  │
  ▼
Models (ActiveRecord)
  ├── Account, User, Session
  ├── Booking, ScheduleCategory
  ├── Resource, ResourceBooking
  └── CustomAttribute, BookingCustomAttribute
  │
  ▼
Database (SQLite)
```

## Multi-tenancy via Account + Current

### How It Works

1. User authenticates, creating a `Session` record
2. A signed cookie (`session_id`) stores the session ID
3. On each request, `Authentication` concern loads the session via the cookie
4. Setting `Current.session` triggers `Current#session=`, which automatically sets `Current.account` from `session.user.account`
5. All controllers scope data through `Current.account`

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session, :account
  delegate :user, to: :session, allow_nil: true

  def session=(session)
    super
    return if user.blank?
    self.account = user.account
  end
end
```

### Request Flow (Authenticated)

```
1. Browser sends request with signed cookie [:session_id]
2. Authentication#require_authentication runs (before_action)
3. Authentication#resume_session finds Session by cookie
4. Current.session = session (triggers Current.account = user.account)
5. ApplicationController#set_language sets I18n.locale from params[:locale]
6. Controller action executes, scoping all queries through Current.account
7. Views render with Current.user and Current.account available
```

### Request Flow (Unauthenticated)

```
1. Browser sends request without cookie (or invalid cookie)
2. Authentication#require_authentication runs
3. Authentication#resume_session returns nil
4. Authentication#request_authentication redirects to new_session_path
5. Return URL is saved in session[:return_to_after_authenticating]
```

## Service Pattern ("Middleware")

Services in `app/middleware/bookings/` follow a convention:

```ruby
module Bookings
  class ServiceName
    def initialize(params...)
      # Store parameters as instance variables
    end

    def call
      # Execute business logic
      # Return result
    end
  end
end
```

Some services (like `Calendar`) also provide a class-level `.call` shortcut:

```ruby
class << self
  def call(account, date)
    new(account, date).call
  end
end
```

Controllers instantiate services and call them:

```ruby
# In controller
info = Bookings::CurrentInfo.new(Current.account, start_on, schedule_category_id).call
```

## Turbo Streams as Interactivity Mechanism

### Check Flow (Calendar + Bookings)

When a user changes the date or schedule category in the booking form, a Turbo Stream request updates the available resources, current info, and custom attributes **without a full page reload**.

```
1. User changes date or schedule category
2. Stimulus booking_controller#update fires
3. POST /bookings/check (or /calendar/check) with Accept: text/vnd.turbo-stream.html
4. Controller calls available_resources, current_info, custom_attributes
5. Response is a Turbo Stream template that replaces DOM elements
6. Turbo.renderStreamMessage(text) applies updates
```

### Create Flow (Calendar)

When a booking is created from the calendar, the response is a Turbo Stream that updates the calendar day cell:

```
1. User submits booking form (from calendar modal)
2. POST /calendar (CalendarController#create)
3. If booking persists: Turbo Stream replaces the day cell with updated bookings
4. If booking fails: Turbo Stream re-renders the form with errors
```

## Complete Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    resources :account, only: %i[show edit update]
    resources :custom_attributes
    resources :users
    resources :resources
    resources :schedule_categories
  end

  resources :bookings do
    collection do
      post :check
    end
  end

  resource :session                          # singular resource
  resources :passwords, param: :token
  resources :calendar, only: %i[index new create] do
    collection do
      post :check
    end
  end
  resources :calendar_events, only: %i[index]

  root to: "calendar#index"
end
```

### Route Summary

| Path | Controller#Action | Purpose |
|------|------------------|---------|
| `GET /` | `calendar#index` | Root, shows monthly calendar |
| `GET /calendar` | `calendar#index` | Monthly calendar view |
| `GET /calendar/new` | `calendar#new` | New booking form (modal) |
| `POST /calendar` | `calendar#create` | Create booking from calendar |
| `POST /calendar/check` | `calendar#check` | Check availability (Turbo Stream) |
| `GET /bookings` | `bookings#index` | List user bookings |
| `GET /bookings/new` | `bookings#new` | New booking form (full page) |
| `POST /bookings` | `bookings#create` | Create booking |
| `GET /bookings/:id/edit` | `bookings#edit` | Edit booking form |
| `PATCH /bookings/:id` | `bookings#update` | Update booking |
| `DELETE /bookings/:id` | `bookings#destroy` | Delete booking |
| `POST /bookings/check` | `bookings#check` | Check availability (Turbo Stream) |
| `GET /calendar_events` | `calendar_events#index` | Day detail events |
| `GET /session/new` | `sessions#new` | Login form |
| `POST /session` | `sessions#create` | Login |
| `DELETE /session` | `sessions#destroy` | Logout |
| `GET /passwords/new` | `passwords#new` | Password reset request form |
| `POST /passwords` | `passwords#create` | Send reset email |
| `GET /passwords/:token/edit` | `passwords#edit` | Password reset form |
| `PATCH /passwords/:token` | `passwords#update` | Update password |
| `GET /admin/users` | `admin/users#index` | List users |
| `GET /admin/resources` | `admin/resources#index` | List resources |
| `GET /admin/schedule_categories` | `admin/schedule_categories#index` | List schedule categories |
| `GET /admin/custom_attributes` | `admin/custom_attributes#index` | List custom attributes |
