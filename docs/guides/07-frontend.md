# 07 - Frontend

## Importmap Configuration

**File:** `config/importmap.rb`

```ruby
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/request.js", to: "@rails--request.js.js" # @0.0.11
```

No bundler (Webpack, esbuild, etc.) is used. All JS is served via importmap.

### JS Dependencies

| Package | Purpose |
|---------|---------|
| `@hotwired/turbo-rails` | Turbo Drive, Frames, and Streams |
| `@hotwired/stimulus` | Stimulus framework |
| `@hotwired/stimulus-loading` | Lazy loading for Stimulus controllers |
| `@rails/request.js` | JS wrapper for Rails UJS-style requests |

---

## Stimulus Controllers

### 1. `booking_controller.js`

**File:** `app/javascript/controllers/booking_controller.js`

The most complex controller. Manages the booking form interaction.

**Targets:**
- `startOn` — date input
- `participants` — number input
- `scheduleCategoryId` — schedule category select
- `message` — resource assignment message area

**Values:**
- `resources` (Object) — map of resource IDs to `{name, max_capacity}`
- `capacity` (Number) — total capacity of available resources
- `translations` (Object) — translated message strings

**Actions:**

| Method | Trigger | Purpose |
|--------|---------|---------|
| `toggle(event)` | Click on resource card | Toggles resource selection |
| `update()` | Change on date or schedule select | POSTs to `/bookings/check` via Turbo Stream |
| `assignedDifference()` | After toggle | Checks if participants exceed capacity |
| `calculatePending()` | Internal | Shows pending/sufficient resource message |

**Key flow:**

```
User changes date/schedule → update() fires
  → POST /bookings/check (Turbo Stream)
  → Server returns updated resources, info, custom attributes
  → Turbo.renderStreamMessage() updates DOM

User toggles resource → toggle(event) fires
  → Adds/removes resource from resourcesAssigned array
  → assignedDifference() recalculates capacity message
```

The `update()` method uses `@rails/request.js` to make a POST request with Turbo Stream accept headers:

```javascript
const resp = await post("/bookings/check", {
  headers: { Accept: "text/vnd.turbo-stream.html" },
  responseKind: "turbo-stream",
  body: JSON.stringify(data),
});
```

---

### 2. `navigation_controller.js`

**File:** `app/javascript/controllers/navigation_controller.js`

**Targets:** `menu`

**Actions:**

| Method | Trigger | Purpose |
|--------|---------|---------|
| `toggle()` | Click | Toggles mobile menu visibility |

Simple controller that toggles the `hidden` class on the menu target.

---

### 3. `colour_picker_controller.js`

**File:** `app/javascript/controllers/colour_picker_controller.js`

**Targets:** `field`, `checked`

**Actions:**

| Method | Trigger | Purpose |
|--------|---------|---------|
| `update({params})` | Click on colour swatch | Sets the hidden field value and updates visual selection |

Used in schedule category admin forms for selecting a colour from AVAILABLE_COLOURS.

---

### 4. `resource_controller.js`

**File:** `app/javascript/controllers/resource_controller.js`

**Targets:** `selected`, `resource`

**Values:** `id` (Number)

**Actions:**

| Method | Trigger | Purpose |
|--------|---------|---------|
| `toggle()` | Click | Toggles resource selection (hidden field + border style) |

Used in booking forms. When a resource card is clicked, it toggles the hidden input value and adds/removes a blue border to indicate selection.

---

### 5. `turbo_modal_controller.js`

**File:** `app/javascript/controllers/turbo_modal_controller.js`

**Targets:** `modalDialog`

**Values:** `background` (Boolean)

**Actions:**

| Method | Trigger | Purpose |
|--------|---------|---------|
| `show()` | `connect()` | Opens the `<dialog>` element |
| `close()` | Click on close button | Closes modal, clears Turbo Frame |
| `submitEnd(event)` | `turbo:submit-end` | Auto-closes on successful redirect |
| `closeWithEsc(event)` | Keydown | Closes on Escape key |

Used for the calendar booking modal. The `connect()` lifecycle callback auto-opens the dialog when the Turbo Frame loads content.

---

### 6. `notice_controller.js`

**File:** `app/javascript/controllers/notice_controller.js`

**Classes:** `show`, `hide`

**Actions:**

| Method | Trigger | Purpose |
|--------|---------|---------|
| `hide()` | setTimeout (3s) | Hides the flash notification |

Auto-hides flash notifications after 3 seconds using CSS class transitions.

---

## Complete Booking Form Interaction Flow

```
┌─────────────────────────────────────────────────────┐
│  1. User opens booking form (new booking)           │
│     → CalendarController#new or BookingsController#new │
│     → Loads schedule categories, resources, info    │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│  2. Form renders with:                               │
│     - Date input (startOn target)                    │
│     - Schedule category select (scheduleCategoryId)  │
│     - Participants number input                      │
│     - Resource cards (toggle on click)               │
│     - Custom attributes (checkboxes)                 │
│     - Current info panel (num bookings, diners)      │
│     - Resource assignment message                    │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│  3. User changes date or schedule category           │
│     → booking_controller#update() fires              │
│     → POST /bookings/check (Turbo Stream)            │
│     → Server recalculates availability               │
│     → Turbo Stream replaces:                         │
│       - Available resources section                  │
│       - Current info panel                           │
│       - Custom attributes section                    │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│  4. User selects resources by clicking cards         │
│     → resource_controller#toggle() toggles hidden input │
│     → booking_controller#toggle() updates tracking   │
│     → Message updates (enough/not enough/exceeded)   │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│  5. User submits form                                │
│     → POST /bookings or POST /calendar               │
│     → Server creates booking + custom attributes     │
│     → Calendar: Turbo Stream updates day cell         │
│     → Bookings: redirect to bookings list             │
└─────────────────────────────────────────────────────┘
```

## Turbo Frames

### Modal Frame

The calendar uses a Turbo Frame for the booking modal:

```erb
<turbo-frame id="modal">
  <!-- Empty by default, loaded when user clicks a day -->
</turbo-frame>
```

When a user clicks a calendar day, a Turbo Frame request loads the `calendar#new` form inside this frame, triggering the `turbo_modal_controller` to show the dialog.

## Turbo Streams

The `check` action in both `CalendarController` and `BookingsController` responds with Turbo Streams that replace specific DOM elements:

- Resources section (available/unavailable resources)
- Current info panel (booking count, participant count)
- Custom attributes section (available/blocked attributes)

The `create` action in `CalendarController` uses Turbo Streams to update the calendar day cell after a successful booking creation.
