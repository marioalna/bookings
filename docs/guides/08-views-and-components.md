# 08 - Views and Components

## Layouts

### `application.html.erb`

**File:** `app/views/layouts/application.html.erb`

The main authenticated layout. Includes:
- Navigation bar with menu links
- Flash notifications via `Notifications::FlashComponent`
- Turbo Frame for modal dialogs
- Main content area

### `public.html.erb`

**File:** `app/views/layouts/public.html.erb`

Used for unauthenticated pages (login, password reset). Simpler layout without navigation.

### `mailer.html.erb` / `mailer.text.erb`

**File:** `app/views/layouts/mailer.html.erb`

Standard Rails mailer layouts for HTML and text emails.

---

## TailwindFormBuilder

**File:** `app/lib/tailwind_form_builder.rb`

A custom form builder that extends `ActionView::Helpers::FormBuilder` to provide Tailwind-styled form elements with consistent error handling.

### CSS Constants

```ruby
LABEL_CLASSES = "text-sm font-medium text-gray-700"
INPUT_CLASSES = "form-input-base px-3 py-2.5 shadow-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 block w-full text-sm border-gray-300 rounded-lg"
INPUT_ERROR_CLASSES = "border-red-300 text-red-900 focus:border-red-500 focus:ring-red-500/20"
SELECT_CLASSES = "form-input-base px-3 py-2.5 shadow-sm ..."
CHECKBOX_CLASSES = "form-checkbox focus:ring-indigo-500 h-5 w-5 text-indigo-600 border-gray-300 rounded"
FILE_CLASSES = "form-input-base block w-full text-sm text-gray-500 ..."
HINT_CLASSES = "text-sm text-gray-500"
HINT_ERROR_CLASSES = "text-sm text-red-600 animate-[fade-in-down_200ms_ease-out]"
FIELD_SPACING = "pt-6"
```

### Available Methods

| Method | Purpose |
|--------|---------|
| `text_input(name, *)` | Standard text input with label and error |
| `float_text_input(name, *)` | Floating label text input |
| `email_input(name, *)` | Email input |
| `float_email_input(name, *)` | Floating label email input |
| `password_input(name, *)` | Password input |
| `float_password_input(name, *)` | Floating label password input |
| `number_input(name, *)` | Number input |
| `area_input(name, *)` | Textarea input |
| `file_input(name, *)` | File upload input |
| `range_input(name, *)` | Range slider input |
| `hidden_input(name, *)` | Hidden field (passthrough) |
| `date_input(name, *)` | Date picker input |
| `time_input(name, *)` | Time picker input (step: 60) |
| `datetime_input(name, *)` | Datetime select |
| `radio_input(name, tag_value, *)` | Radio button with label |
| `fancy_radio_input(name, tag_value, *)` | Styled radio card with description |
| `check_input(name, *)` | Checkbox with label |
| `collection_select_input(name, collection, ...)` | Select from collection |
| `collection_time_select(name, ...)` | Time select from collection |
| `submit_button(name, *)` | Green submit button |

### Error Handling Pattern

Every input method follows this pattern:

```ruby
def input_element(field_type, name, *args)
  options = args.extract_options!
  message = options.fetch(:message, error_message(name))
  error = options.fetch(:error, any_errors?(name))

  content_tag(:div, { class: "form-element #{FIELD_SPACING}", id: "field-#{name}" }) do
    concat(label(..., class: LABEL_CLASSES + (error ? " text-red-700" : "")))
    concat(content_tag(:div, { class: "relative mt-2 rounded-lg shadow-sm" }) do
      concat(send(field_type, name, { class: INPUT_CLASSES + (error ? " #{INPUT_ERROR_CLASSES}" : "") }))
      concat(error_icon) if error.present?
    end)
    concat(hint_message(message, error))
  end
end
```

### Floating Labels

The `float_*` variants use CSS peer classes for a Material Design-style floating label effect:

```ruby
class: "absolute text-sm pt-2 text-gray-500 duration-300 transform -translate-y-4 scale-75 top-2 z-10 origin-[0] px-2 peer-focus:px-2 peer-focus:text-blue-600 peer-placeholder-shown:scale-100 peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2 peer-focus:top-2 peer-focus:scale-75 peer-focus:-translate-y-4 left-1"
```

### Usage via Helper

```ruby
# app/helpers/form_tailwind_helper.rb
module FormTailwindHelper
  def tw_form_with(**args, &)
    args.merge!({ builder: TailwindFormBuilder, ref: 'form' })
    form_with(**args, &)
  end
end
```

In views: `tw_form_with(model: @booking) do |f|`

---

## FlashComponent (ViewComponent)

**File:** `app/components/notifications/flash_component.rb`

```ruby
module Notifications
  class FlashComponent < ViewComponent::Base
    attr_reader :flash

    def initialize(flash)
      @flash = flash
    end

    def render?
      flash.any?
    end

    def banner_type(type)
      case type.to_s
      when "alert", "error"
        "bg-red-800 text-red-100"
      else
        "bg-indigo-800 text-indigo-100"
      end
    end
  end
end
```

**Template:** `app/components/notifications/flash_component.html.haml`

Renders flash notifications as a fixed-position banner at the top of the page. Uses the `notice_controller` Stimulus controller to auto-hide after 3 seconds.

**Note:** The `banner_type` method is defined but the template uses hardcoded green styles instead. The template always renders a green success-style notification regardless of flash type.

---

## Helpers

### StylesHelper (`app/helpers/styles_helper.rb`)

Provides `class_variants` for colours, tables, and labels:

- `TEXT_COLOURS` — hash mapping colour names to Tailwind background + text classes
- `colour_styles(colour)` — returns Tailwind classes for a colour
- `span_with_colour(text, colour, rounded, size)` — renders a coloured span tag
- `icon_tag(icon)` — renders an SVG icon from `assets/images/icons/`
- `colour_class`, `list_class`, `label_class`, `td_class`, `th_class` — `class_variants` for various UI elements

### LinksHelper (`app/helpers/links_helper.rb`)

Provides `class_variants` for links, buttons, and navigation:

- `link_class` — styled link with variants: `border`, `popup`, `icon`
- `dropdown_class` — dropdown menu item
- `button_class` — button with variants for `style` (primary, secondary, edit, action, danger, new, print), `size`, and `shape`
- `submit_button_class` — submit button with variants for `style` (primary, secondary, auth, danger) and `size`
- `sidebar_class`, `sidebar_icon_class` — sidebar navigation

### BookingsHelper (`app/helpers/bookings_helper.rb`)

- `can_edit?(booking)` — authorization check (admin or own future booking)
- `resources_for_frontend(resources)` — converts resources to JS-friendly hash
- `capacity_for_frontend(available_resources)` — sums max_capacity of available resources
- `translations_for_frontend` — provides translation strings for the booking Stimulus controller

### MenuHelper (`app/helpers/menu_helper.rb`)

- `user_menu_links` — returns array of user dropdown menu items
- `selected_option(current_link)` — returns CSS classes for active/inactive nav links

### ResourcesHelper (`app/helpers/resources_helper.rb`)

- `selected_resource_booking(params, resource_booking_id)` — extracts selected resource from nested params
- `resource_image(resource)` — returns URL for resource photo or default image

### FormStylesHelper (`app/helpers/form_styles_helper.rb`)

- `form_card_class` — card container with padding and width variants
- `form_title_class` — form title with size variants
- `form_actions_class` — form action row (buttons)
- `form_row_class` — grid row with column variants

### FormTailwindHelper (`app/helpers/form_tailwind_helper.rb`)

- `tw_form_with(**args, &)` — wraps `form_with` to use `TailwindFormBuilder`

### ApplicationHelper (`app/helpers/application_helper.rb`)

Empty module.

---

## View Structure

```
app/views/
  ├── layouts/
  │     ├── application.html.erb      # Main authenticated layout
  │     ├── public.html.erb           # Unauthenticated layout
  │     ├── mailer.html.erb           # Email HTML layout
  │     └── mailer.text.erb           # Email text layout
  ├── calendar/                       # Calendar views (HAML)
  │     ├── index.html.haml           # Monthly calendar grid
  │     ├── new.html.haml             # New booking modal form
  │     ├── create.turbo_stream.haml  # Turbo Stream for create
  │     └── check.turbo_stream.haml   # Turbo Stream for check
  ├── bookings/                       # Bookings views (HAML)
  │     ├── index.html.haml           # Bookings list
  │     ├── new.html.haml             # New booking form
  │     ├── edit.html.haml            # Edit booking form
  │     └── check.turbo_stream.haml   # Turbo Stream for check
  ├── calendar_events/                # Day detail view
  │     └── index.html.haml
  ├── sessions/                       # Auth views (HAML)
  │     └── new.html.haml             # Login form
  ├── passwords/                      # Password views (HAML)
  │     ├── new.html.haml             # Reset request form
  │     └── edit.html.haml            # Reset form
  ├── admin/                          # Admin views (HAML)
  │     ├── users/
  │     ├── resources/
  │     ├── schedule_categories/
  │     └── custom_attributes/
  ├── shared/                         # Shared partials
  └── passwords_mailer/               # Password reset email templates
```
