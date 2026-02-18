# 01 - Overview

## What is Sociedad?

Sociedad (BookingsApp) is a Rails 8 application for managing and booking shared resources, originally designed for **gastronomic societies** (sociedades gastronómicas). These are traditional social clubs in the Basque Country where members share kitchen facilities, dining rooms, and equipment.

Users can:
- View a monthly calendar with booking information
- Make bookings with schedule categories (e.g., morning, afternoon)
- Select resources (e.g., dining rooms) and custom attributes (e.g., oven)
- Manage their own bookings

Admins can:
- Manage users, resources, schedule categories, and custom attributes
- Edit/delete any booking regardless of ownership or date

## Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Ruby on Rails | 8.0.2 |
| Language | Ruby | 3.3.6 |
| Database | SQLite | >= 2.1 |
| Views | HAML | (latest) |
| Layouts | ERB | (Rails default) |
| CSS | Tailwind CSS | v4 via `tailwindcss-rails` 4.1.0 |
| JS | Importmap | (no bundler) |
| Interactivity | Hotwire (Turbo + Stimulus) | (Rails default) |
| HTTP requests | @rails/request.js | 0.0.11 |
| Components | ViewComponent | (latest) |
| Assets | Propshaft | (latest) |
| Auth | bcrypt (`has_secure_password`) | ~> 3.1.7 |
| CSS Variants | class_variants gem | (latest) |
| Deployment | Kamal + Docker | (latest) |
| Web Server | Puma + Thruster | >= 6.0 |
| Background Jobs | Solid Queue | (latest) |
| Cache | Solid Cache | (latest) |
| WebSockets | Solid Cable | (latest) |
| Image Processing | image_processing + libvips | ~> 1.2 |

### Development Dependencies

| Gem | Purpose |
|-----|---------|
| `brakeman` | Security scanner |
| `rubocop-rails-omakase` | Linting (Rails omakase style) |
| `faker` | Test data generation |
| `parallel_tests` | Parallel test execution |
| `hotwire-spark` | Hot reload for Hotwire |
| `letter_opener` | Preview emails in browser |
| `capybara` + `selenium-webdriver` | System tests |
| `database_cleaner` | Test database cleanup |
| `rails-controller-testing` | Controller test helpers |

## Design Decisions

### Simple Multi-tenancy via Account
All data is scoped through an `Account` model. The `Current` model (`ActiveSupport::CurrentAttributes`) propagates the account context from the authenticated session to all controllers and services. See [02-architecture.md](02-architecture.md).

### Service Objects in `app/middleware/`
Business logic for bookings lives in `app/middleware/bookings/`, not in models or controllers. This is a non-standard directory name (not Rack middleware) but it's autoloaded by Rails. See [05-service-layer.md](05-service-layer.md).

### `class_variants` for CSS
The `class_variants` gem provides a pattern similar to CVA (Class Variance Authority) for building Tailwind CSS class strings with variants. Used extensively in helpers. See [08-views-and-components.md](08-views-and-components.md).

### TailwindFormBuilder
A custom form builder (`app/lib/tailwind_form_builder.rb`) wraps all standard Rails form fields with consistent Tailwind styling, error handling, and floating label support. See [08-views-and-components.md](08-views-and-components.md).

## Essential Development Commands

```bash
bin/dev                          # Start dev server (Rails + Tailwind watcher via foreman)
bin/rails test                   # Run all unit/integration tests
bin/rails test test:system       # Run all tests including system tests
bin/rails test test/models/booking_test.rb          # Run a single test file
bin/rails test test/models/booking_test.rb:42       # Run a single test at line
bin/rails db:test:prepare        # Prepare test database
bin/rubocop                      # Lint with RuboCop
bin/brakeman --no-pager          # Security scan
bin/importmap audit              # JS dependency security audit
```

## Non-standard Directory Structure

```
app/
  middleware/bookings/     # Service objects (NOT Rack middleware)
  lib/                     # TailwindFormBuilder
  components/              # ViewComponent classes
  form_builders/           # (empty, builder is in app/lib/)
```

The `app/middleware/` directory is autoloaded by Rails and contains domain service objects following an `initialize/call` convention. Despite the name, these are not Rack middleware.
