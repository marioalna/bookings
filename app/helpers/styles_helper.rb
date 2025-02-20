module StylesHelper
  TEXT_COLOURS = {
    red: "bg-red-100 text-red-800",
    green: "bg-green-100 text-green-800",
    yellow: "bg-yellow-100 text-yellow-800",
    blue: "bg-blue-100 text-blue-800",
    indigo: "bg-indigo-100 text-indigo-800",
    purple: "bg-purple-100 text-purple-800",
    pink: "bg-pink-100 text-pink-800",
    orange: "bg-orange-100 text-orange-800",
    teal: "bg-teal-100 text-teal-800",
    cyan: "bg-cyan-100 text-cyan-800",
    gray: "bg-gray-100 text-gray-800",
    white: "bg-white text-gray-800",
    black: "bg-black text-white",
    amber: "bg-amber-100 text-amber-800",
    lime: "bg-lime-100 text-lime-800",
    emerald: "bg-emerald-100 text-emerald-800",
    rose: "bg-rose-100 text-rose-800",
    sky: "bg-sky-100 text-sky-800",
    violet: "bg-violet-100 text-violet-800",
    fuchsia: "bg-fuchsia-100 text-fuchsia-800",
    slate: "bg-slate-100 text-slate-800"
  }.freeze

  def colour_styles(colour)
    TEXT_COLOURS[colour.to_sym]
  end

  def span_with_colour(text, object_colour, rounded = :md, size = :sm)
    colour = object_colour.present? ? object_colour.to_sym : :slate
    content_tag :span, text, class: colour_class.render(colour:, rounded:, size:)
  end

  def icon_tag(icon)
    icon = "no-symbol" if icon.blank?

    image_tag "icons/#{icon}.svg", class: "h-5 w-5"
  end

  def colour_class
    class_variants(
      base: "inline-flex items-center px-2.5 py-0.5 font-medium",
      variants: {
        colour: TEXT_COLOURS,
        rounded: {
          full: "rounded-full",
          md: "rounded-md"
        },
        size: {
          xs: "text-xs",
          sm: "text-sm",
          lg: "text-lg",
          xl: "text-xl"
        }
      },
      defaults: {
        colour: :slate,
        rounded: :md,
        size: :sm
      }
    )
  end

  def list_class
    class_variants(
      base: "flex-1",
      variants: {
        colour: TEXT_COLOURS,
        rounded: {
          full: "rounded-full",
          lg: "rounded-lg",
          md: "rounded-md",
          none: ""
        }
      },
      defaults: {
        colour: :slate,
        rounded: :none
      }
    )
  end

  def label_class
    class_variants(
      base: "text-sm font-medium text-gray-700"
    )
  end

  def td_class
    class_variants(
      base: "p-2 whitespace-no-wrap text-sm leading-5 font-medium text-gray-900",
      variants: {
        text_align: {
          left: "text-left",
          center: "text-center",
          right: "text-right"
        }
      },
      defaults: {
        text_align: :left
      }
    )
  end

  def th_class
    class_variants(
      base: "p-3 border-b border-gray-200 bg-gray-50 text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider",
      variants: {
        text_align: {
          left: "text-left",
          center: "text-center",
          right: "text-right"
        }
      },
      defaults: {
        text_align: :left
      }
    )
  end
end
