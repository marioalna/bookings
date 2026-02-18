# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BookingsApp ("Sociedad") — a Rails 8 application for managing and booking shared resources (originally designed for gastronomic societies). Users can view a calendar, make bookings with schedule categories, and manage resources. Admins have a separate panel for managing users, resources, schedule categories, and custom attributes.

## Development Commands

```bash
bin/dev                          # Start dev server (Rails + Tailwind watcher via foreman)
bin/rails test                   # Run all unit/integration tests
bin/rails test test:system       # Run all tests including system tests
bin/rails test test/models/booking_test.rb          # Run a single test file
bin/rails test test/models/booking_test.rb:42       # Run a single test at line
bin/rails db:test:prepare        # Prepare test database
bin/rubocop                      # Lint with RuboCop (rubocop-rails-omakase style)
bin/brakeman --no-pager          # Security scan
bin/importmap audit              # JS dependency security audit
```

## Architecture

### Multi-tenancy via Account

All data is scoped through `Account`. The `Current` model (`ActiveSupport::CurrentAttributes`) sets `Current.session` and `Current.account` from the authenticated user. Controllers access data through `Current.account` (e.g., `Current.account.bookings`, `Current.account.resources`).

### Middleware Layer (app/middleware/bookings/)

Business logic for bookings lives in service objects under `app/middleware/bookings/`, not in models or controllers. Key classes:
- `Bookings::Calendar` — builds monthly calendar data with aggregated booking info
- `Bookings::Finder` — filters bookings by user, resource, or date range
- `Bookings::AvailableResources` — checks resource availability for a booking
- `Bookings::CurrentInfo` — gets current booking stats for a date/schedule
- `Bookings::CustomAttributes` — manages custom attribute availability
- `Bookings::ResourceChecker` — validates resource capacity constraints
- `Bookings::BookingCustomAttributes` — creates/updates custom attribute associations

### Admin Namespace

Admin controllers inherit from `AdminController` (not `ApplicationController` directly), which enforces admin role check. The `User` model has an enum role: `regular` (0) and `admin` (9).

### Authentication

Cookie-based session auth via `Authentication` concern. Uses `has_secure_password` (bcrypt). Password reset uses time-limited tokens stored on the User model.

### Key Technical Choices

- **Database**: SQLite (development, test, and production)
- **Views**: HAML for most views, ERB for layouts
- **CSS**: Tailwind CSS v4 (via `tailwindcss-rails` gem)
- **JS**: Importmap (no bundler), Stimulus controllers, Turbo (Hotwire)
- **Components**: ViewComponent (currently `Notifications::FlashComponent`)
- **Assets**: Propshaft
- **I18n**: Default locale is `:es` (Spanish), with `:en` available
- **Time zone**: Madrid
- **Testing**: Minitest with fixtures, Capybara + Selenium for system tests
- **Deployment**: Kamal with Docker

### Domain Model

`Account` → has many `Users`, `Resources`, `ScheduleCategories`, `CustomAttributes`
`User` → has many `Bookings`, `Sessions`
`Booking` → belongs to `User` and `ScheduleCategory`, has many `Resources` (through `ResourceBookings`), has many `CustomAttributes` (through `BookingCustomAttributes`)

### Test Structure

Tests use fixtures (in `test/fixtures/`) and helper methods `log_in_admin` / `log_in_user` from `test_helper.rb`. Tests are organized as:
- `test/models/` — model validations and logic
- `test/integration/` — controller tests
- `test/middleware/bookings/` — service object tests
