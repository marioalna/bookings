# 09 - Internationalization

## Configuration

**File:** `config/application.rb`

```ruby
config.i18n.available_locales = %i[en es]
config.i18n.default_locale = :es
```

- Default locale: `:es` (Spanish)
- Available locales: `:en` (English) and `:es` (Spanish)
- Locale is set per-request via `params[:locale]` in `ApplicationController#set_language`

```ruby
# app/controllers/application_controller.rb:7
def set_language
  I18n.locale = params[:locale] || I18n.default_locale
end
```

## Locale Files

| File | Locale | Status |
|------|--------|--------|
| `config/locales/es.yml` | Spanish | Complete |
| `config/locales/en.yml` | English | Incomplete (see issues below) |

## Key Structure

### Top-level Sections

| Section | Purpose |
|---------|---------|
| `admin.*` | Admin panel labels and messages |
| `buttons.*` | Shared button labels (cancel, delete, edit, save) |
| `bookings.*` | Booking form labels, errors, and messages |
| `calendar.*` | Day names and calendar title |
| `date.*` | Date formatting and month/day names |
| `formErrors.*` | Form validation error messages |
| `menu.*` | Navigation menu labels |
| `passwords.*` | Password reset form and messages |
| `sessions.*` | Login form and messages |

### Admin Subsections

| Key Path | Purpose |
|----------|---------|
| `admin.customAttributes.*` | Custom attributes CRUD messages |
| `admin.resources.*` | Resources CRUD messages |
| `admin.scheduleCategories.*` | Schedule categories CRUD messages |
| `admin.users.*` | Users CRUD messages |

### Booking Keys

| Key | es | en |
|-----|----|----|
| `bookings.created` | Reserva creada | Booking created |
| `bookings.updated` | Reserva actualizada | Booking updated |
| `bookings.deleted` | Reserva eliminada | Booking deleted |
| `bookings.currentInfo` | Para el horario %{schedule_name} hay un total de %{num_bookings} reservas y %{participants} comensales. | For %{schedule_name} schedule there are %{num_bookings} bookings with %{participants} diners. |
| `bookings.errors.userTaken` | No puedes realizar otra reserva para el mismo dia y horario | already have a booking for this day and schedule. |
| `bookings.errors.invalidDate` | Tienes que seleccionar una fecha a futuro. | You have to choose a future date |
| `bookings.errors.invalidSchedule` | Horario no valido | Invalid schedule |
| `bookings.errors.noResourcesAvailable` | No hay recursos disponibles... | (see issue below) |
| `bookings.errors.takenByUser` | Ya tienes una reservado... | (Spanish in en.yml!) |
| `bookings.errors.takenByOtherUser` | Otro usuario ya tiene... | (Spanish in en.yml!) |
| `bookings.assign.enough` | Ya tienes suficientes recursos asignados. | You have enough resources assigned. |
| `bookings.assign.notEnough` | Tienes pendiente asignar espacio para X comensales. | You have X diners pending to assign. |
| `bookings.assign.exceeded` | El limite de comensales es XX, lo excedes por YY comensales. | You exceed the limit of diners. |

---

## Known Issues

### Issue 1: Spanish Text in `en.yml` (BUG-08)

**File:** `config/locales/en.yml`

Lines 54-56 contain Spanish text under the English locale:

```yaml
en:
  bookings:
    errors:
      noResourcesAvailable: "No hay recursos disponibles para esta fecha y horario."
      takenByUser: "Ya tienes una reservado este recurso para esta fecha y horario."
      takenByOtherUser: "Otro usuario ya tiene reservado este recurso para esta fecha y horario."
```

These should be translated to English. Note that `noResourcesAvailable` is duplicated (lines 51 and 54), with the first occurrence in English and the second in Spanish — YAML will use the last value.

### Issue 2: Missing `admin.customAttributes` Section in `en.yml` (BUG-09)

The `es.yml` file has an `admin.customAttributes` section with all CRUD keys:

```yaml
es:
  admin:
    customAttributes:
      addFirst: "Anade el primer atributo adicional"
      created: "Atributo adicional creado"
      # ... more keys
```

The `en.yml` file is missing this entire section. Any page that uses `t('admin.customAttributes.*')` in English will show the raw key path.

### Issue 3: Missing `t()` Call in PasswordsController (BUG-03)

**File:** `app/controllers/passwords_controller.rb:31`

```ruby
redirect_to new_password_path, alert: ('passwords.reset.invalid')
```

Missing `t()` call — displays the raw string `'passwords.reset.invalid'` instead of the translated message.

### Issue 4: Missing `bookings.customAttributes` Key in `en.yml`

The `es.yml` has `bookings.customAttributes: "Atributos adicionales"` but this key is missing from `en.yml`.

### Issue 5: Missing `menu.customAttributes` Key in `en.yml`

The `es.yml` has `menu.customAttributes: "Atributos adicionales"` but this key is missing from `en.yml`.

### Issue 6: Structural Difference in `date` Section

In `es.yml`, date formats are under `date.formats`:
```yaml
es:
  date:
    formats:
      default: "%-d-%m-%Y"
```

In `en.yml`, there's a duplicate — `date.default` at the top level AND `date.formats.default`:
```yaml
en:
  date:
    default: "%-d-%m-%Y"         # Wrong level
    formats:
      default: "%-d-%m-%Y"       # Correct level
```

### Issue 7: Missing Date Translations in `en.yml`

The `es.yml` has full `date.abbr_day_names`, `date.day_names`, `date.abbr_month_names`, and `date.month_names` arrays. The `en.yml` is missing all of these (relies on Rails defaults for English, which is fine for English but indicates incomplete parity).
