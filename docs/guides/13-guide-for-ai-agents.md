# 13 - Guide for AI Agents

Quick reference for AI agents working on this codebase.

## Project at a Glance

- **Rails 8** app for booking shared resources (gastronomic societies)
- **SQLite** database, **HAML** views, **Tailwind CSS v4**, **Hotwire** (Turbo + Stimulus)
- Default locale: **Spanish** (`:es`), English also available
- Multi-tenancy via `Account` scoped through `Current.account`

## Where to Put New Code

| Type | Location | Pattern |
|------|----------|---------|
| Business logic / services | `app/middleware/bookings/` | `initialize(params)` + `call` method |
| Controllers (public) | `app/controllers/` | Inherit from `ApplicationController` |
| Controllers (admin) | `app/controllers/admin/` | Inherit from `AdminController` |
| Stimulus controllers | `app/javascript/controllers/` | `xxx_controller.js` |
| ViewComponents | `app/components/` | `ModuleName::ComponentName` |
| Helpers | `app/helpers/` | Use `class_variants` for CSS variant patterns |
| Form builder | `app/lib/` | Extends `ActionView::Helpers::FormBuilder` |
| Views | `app/views/` | HAML (`.html.haml`) for views, ERB for layouts |
| Tests (models) | `test/models/` | Minitest |
| Tests (controllers) | `test/integration/` | Minitest |
| Tests (services) | `test/middleware/bookings/` | Minitest |
| Fixtures | `test/fixtures/` | YAML with ERB |
| Locale files | `config/locales/` | `es.yml` and `en.yml` |

## Patterns to Follow

### Service Objects

```ruby
module Bookings
  class MyService
    def initialize(account, params)
      @account = account
      @params = params
    end

    def call
      # business logic here
      result
    end

    private
      attr_reader :account, :params
  end
end
```

### Admin CRUD Controller

```ruby
class Admin::ThingsController < AdminController
  before_action :find_thing, only: %i[edit update destroy]

  def index
    @things = Current.account.things
  end

  def new
    @thing = Current.account.things.new
  end

  def create
    @thing = Current.account.things.new(thing_params)
    if @thing.save
      redirect_to admin_things_path, notice: t("admin.things.created")
    else
      render "new", status: :unprocessable_entity
    end
  end

  # ... edit, update, destroy follow the same pattern

  private
    def thing_params
      params.require(:thing).permit(:name, :other_field)
    end

    def find_thing
      @thing = Current.account.things.find(params[:id])
    end
end
```

### Form Builder Usage

```haml
= tw_form_with(model: @thing, url: admin_things_path) do |f|
  = f.text_input :name, label: t("admin.things.name")
  = f.number_input :capacity, label: t("admin.things.capacity")
```

### Turbo Stream Responses

```haml
-# check.turbo_stream.haml
= turbo_stream.replace "resources_section" do
  = render partial: "resources", locals: { resources: @available_resources }

= turbo_stream.replace "current_info" do
  = render partial: "current_info", locals: { ... }
```

## Common Mistakes to Avoid

### 1. Forgetting Account Scope

Always scope queries through `Current.account`:

```ruby
# WRONG
Resource.all
User.find(params[:id])

# CORRECT
Current.account.resources
Current.account.users.find(params[:id])
```

### 2. Missing i18n in Both Locales

When adding new translation keys, always add them to **both** `es.yml` and `en.yml`:

```yaml
# config/locales/es.yml
es:
  my_feature:
    title: "Mi titulo"

# config/locales/en.yml
en:
  my_feature:
    title: "My title"
```

### 3. Using `create` + `save` (Double Save)

```ruby
# WRONG (existing bug in admin controllers)
@thing = Current.account.things.create(thing_params)
if @thing.save  # redundant

# CORRECT
@thing = Current.account.things.new(thing_params)
if @thing.save
```

### 4. Forgetting `dependent: :destroy`

When adding `has_many` associations, consider whether child records should be destroyed when the parent is deleted:

```ruby
has_many :child_records, dependent: :destroy
```

### 5. Not Using `Current.user` for Authorization

```ruby
# Check admin status
Current.user.admin?

# Scope bookings by role
if Current.user.admin?
  Current.account.bookings.find(params[:id])
else
  Current.user.bookings.find(params[:id])
end
```

## Running Tests

```bash
bin/rails test                              # All tests
bin/rails test test/models/                 # Model tests only
bin/rails test test/integration/            # Integration tests only
bin/rails test test/middleware/             # Service tests only
bin/rails test test/models/user_test.rb     # Single file
bin/rails test test/models/user_test.rb:10  # Single test
```

## Key Files Reference

| Purpose | File |
|---------|------|
| Routes | `config/routes.rb` |
| Database schema | `db/schema.rb` |
| Application config | `config/application.rb` |
| Authentication | `app/controllers/concerns/authentication.rb` |
| Current context | `app/models/current.rb` |
| Form builder | `app/lib/tailwind_form_builder.rb` |
| Global constants | `config/initializers/sociedad.rb` |
| Spanish locale | `config/locales/es.yml` |
| English locale | `config/locales/en.yml` |
| Test helper | `test/test_helper.rb` |

## Pending Bugs

Before starting new work, review the 15 known bugs in [12-bugs-and-tech-debt.md](12-bugs-and-tech-debt.md). Critical issues:

1. **BUG-01**: Password reset is broken (`find_by_password_reset_token!`)
2. **BUG-02**: Booking model validates non-existent `colour` column
3. **BUG-06**: `BookingCustomAttributes` loop aborts on first invalid ID
4. **BUG-11**: Missing `dependent: :destroy` causes orphaned records
