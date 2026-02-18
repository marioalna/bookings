module LinksHelper
  def link_class
    class_variants(
      base: "text-sm leading-4 font-medium text-indigo-700 hover:text-indigo-500 focus:outline-none focus:shadow-outline-indigo active:bg-indigo-200 transition ease-in-out duration-150",
      variants: {
        border: "border border-transparent rounded-md focus:border-indigo-300 bg-indigo-100 hover:bg-indigo-50",
        popup: "px-4 py-2 hover:bg-indigo-100 focus:outline-none focus:shadow-outline-indigo active:bg-indigo-100",
        icon: "px-4 py-2 inline-flex items-center"
      }
    )
  end

  def dropdown_class
    class_variants(
      base: "px-4 py-2 inline-flex items-center text-sm leading-4 w-full font-medium text-sky-700 hover:bg-sky-100 hover:text-sky-500 focus:outline-none focus:shadow-outline-sky active:bg-sky-200 transition ease-in-out duration-150"
    )
  end

  def button_class
    class_variants(
      base: "inline-flex items-center border border-transparent leading-4 font-medium focus:outline-none transition ease-in-out duration-150",
      variants: {
        style: {
          primary: "bg-indigo-600 text-white hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700",
          secondary: "focus:border-indigo-300 text-indigo-700 bg-indigo-100 hover:bg-indigo-50 focus:shadow-outline-indigo active:bg-indigo-200",
          edit: "text-teal-700 bg-teal-100 hover:bg-teal-50 focus:outline-none focus:border-teal-300 focus:shadow-outline-teal active:bg-teal-200",
          action: "focus:border-fuchsia-300 text-fuchsia-700 bg-fuchsia-100 hover:bg-fuchsia-50 focus:shadow-outline-fuchsia active:bg-fuchsia-200",
          danger: "text-red-700 bg-red-100 hover:bg-red-50 focus:outline-none focus:border-red-300 active:bg-red-200",
          new: "text-blue-700 bg-blue-100 hover:bg-blue-50 focus:outline-none focus:border-blue-300 active:bg-blue-200",
          print: "rounded-md bg-white font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
        },
        size: {
          small: "px-2 py-1 text-xs",
          medium: "px-3 py-2 text-sm",
          large: "px-4 py-2 text-sm"
        },
        shape: {
          default: "rounded-md",
          pill: "rounded-full",
          rounded: "rounded-lg"
        }
      },
      defaults: {
        style: :primary,
        size: :small,
        shape: :default
      }
    )
  end

  def submit_button_class
    class_variants(
      base: "inline-flex items-center justify-center font-semibold shadow-sm transition ease-in-out duration-150 focus:outline-none cursor-pointer",
      variants: {
        style: {
          primary: "bg-indigo-600 text-white hover:bg-indigo-700 focus:ring-2 focus:ring-indigo-500/50 active:bg-indigo-800 rounded-full",
          secondary: "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 focus:ring-2 focus:ring-indigo-500/50 active:bg-gray-100 rounded-lg",
          auth: "bg-blue-600 text-white hover:bg-blue-700 focus:ring-2 focus:ring-blue-500/50 active:bg-blue-800 rounded-lg",
          danger: "bg-red-600 text-white hover:bg-red-700 focus:ring-2 focus:ring-red-500/50 active:bg-red-800 rounded-lg"
        },
        size: {
          small: "px-3 py-2 text-sm",
          medium: "px-3.5 py-2.5 text-sm",
          large: "px-5 py-3 text-base",
          full: "w-full py-3 text-sm"
        }
      },
      defaults: {
        style: :primary,
        size: :medium
      }
    )
  end

  def sidebar_icon_class
    class_variants(
      base: "mr-3 h-6 w-6 text-hq-blue-700 group-hover:text-hq-blue-600 ease-in-out duration-150"
    )
  end

  def sidebar_class
    class_variants(
      base: "group flex items-center px-2 py-2 text-sm text-hq-blue-700 leading-5 font-medium rounded-md hover:bg-hq-pink-300 focus:bg-hq-pink-300 hover:text-hq-blue-700 focus:outline-none ease-in-out duration-150",
      variants: {
        bg: {
          transparent: "bg-transparent",
          selected: "bg-hq-pink-300"
        }
      },
      defaults: {
        bg: :transparent
      }
    )
  end
end
