# 04 - Authentication and Authorization

## Authentication

### Overview

The application uses cookie-based session authentication implemented via the `Authentication` concern (`app/controllers/concerns/authentication.rb`). There is no token-based API auth or OAuth.

### Authentication Concern

```ruby
# app/controllers/concerns/authentication.rb
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end
end
```

All controllers inherit from `ApplicationController`, which includes `Authentication`. This means **all routes require authentication by default**. Controllers opt out with:

```ruby
allow_unauthenticated_access only: %i[new create]
```

### Login Flow

1. User visits any page -> redirected to `GET /session/new` (login form)
2. Return URL saved in `session[:return_to_after_authenticating]`
3. User submits email + password -> `POST /session`
4. `User.authenticate_by(email:, password:)` verifies credentials (bcrypt)
5. On success: `start_new_session_for(user)` creates a `Session` record and sets signed cookie
6. On failure: redirect back with alert message

### Session Management

```ruby
# Authentication#start_new_session_for
def start_new_session_for(user)
  user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
    Current.session = session
    cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
  end
end
```

- Sessions are stored in the `sessions` database table (not Rails session store)
- Cookie is `httponly`, `same_site: :lax`, and **permanent** (no expiry)
- Each session records `user_agent` and `ip_address`

### Session Resumption

On each request:

```ruby
def resume_session
  Current.session ||= find_session_by_cookie
end

def find_session_by_cookie
  Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
end
```

Setting `Current.session` automatically sets `Current.account` via the custom setter in `Current`.

### Logout

```ruby
def terminate_session
  Current.session.destroy
  cookies.delete(:session_id)
end
```

### Rate Limiting

Login attempts are rate-limited:

```ruby
# app/controllers/sessions_controller.rb:3
rate_limit to: 10, within: 3.minutes, only: :create,
           with: -> { redirect_to new_session_url, alert: t('sessions.tryAgain') }
```

10 attempts per 3 minutes.

## Password Reset

### Flow

1. User clicks "Forgot password?" -> `GET /passwords/new`
2. User submits email -> `POST /passwords`
3. If email exists, `PasswordsMailer.reset(user).deliver_later` sends reset email
4. Always redirects with "instructions sent" message (prevents email enumeration)
5. User clicks link in email -> `GET /passwords/:token/edit`
6. `set_user_by_token` finds user by token
7. User submits new password -> `PATCH /passwords/:token`

### Bug: `find_by_password_reset_token!`

The `PasswordsController#set_user_by_token` method (line 29) calls:

```ruby
@user = User.find_by_password_reset_token!(params[:token])
```

This method comes from Rails 8's `has_secure_password` token generation, but the `User` model uses a **custom token system** (`reset_token` + `reset_expires_at`) instead. The model has its own `validate_reset_values` and `enable_reset_password` methods, but `find_by_password_reset_token!` is not connected to them. See [12-bugs-and-tech-debt.md](12-bugs-and-tech-debt.md) BUG-01.

### Another Bug: Missing `t()` Call

In `app/controllers/passwords_controller.rb:31`:

```ruby
redirect_to new_password_path, alert: ('passwords.reset.invalid')
```

The `t()` helper is missing, so the raw string `'passwords.reset.invalid'` is displayed instead of the translated text.

## Authorization

### Roles

The `User` model defines two roles via integer enum:

```ruby
enum :role, { regular: 0, admin: 9 }
```

Constants are also defined:
```ruby
REGULAR = "regular".freeze
ADMIN = "admin".freeze
```

### AdminController

```ruby
# app/controllers/admin_controller.rb
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

All admin controllers inherit from `AdminController`, which checks `Current.user.role == User::ADMIN` before every action. Non-admin users are silently redirected to the calendar.

### `can_edit?` Helper

```ruby
# app/helpers/bookings_helper.rb:2
def can_edit?(booking)
  Current.user.role == User::ADMIN || (booking.user == Current.user && booking.start_on >= Date.current)
end
```

Regular users can only edit/delete their own **future** bookings. Admins can edit any booking regardless of ownership or date.

### Booking Date Validation

```ruby
# app/models/booking.rb
validates :start_on, comparison: { greater_than_or_equal_to: Date.current },
          unless: :current_user_is_admin?
```

Admins can create bookings in the past. Regular users cannot.

### Context Propagation

```
Cookie -> Session -> Current.session -> Current.user -> Current.account
```

All controllers access the current context via `Current`:
- `Current.user` - the authenticated user
- `Current.account` - the user's account (for scoping all queries)
- `Current.session` - the database session record
