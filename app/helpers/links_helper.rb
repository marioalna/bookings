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
      base: "inline-flex items-center border border-transparent leading-4 font-medium rounded focus:outline-none transition ease-in-out duration-150",
      variants: {
        style: {
          primary: "bg-indigo-600 text-white hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700",
          secondary: "focus:border-indigo-300 text-indigo-700 bg-indigo-100 hover:bg-indigo-50 focus:shadow-outline-indigo active:bg-indigo-200",
          edit: "text-teal-700 bg-teal-100 hover:bg-teal-50 focus:outline-none focus:border-teal-300 focus:shadow-outline-teal active:bg-teal-200",
          action: "focus:border-fuchsia-300 text-fuchsia-700 bg-fuchsia-100 hover:bg-fuchsia-50 focus:shadow-outline-fuchsia active:bg-fuchsia-200",
          print: "rounded-md bg-white font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
        },
        size: {
          small: "px-2 py-1 text-xs",
          medium: "px-3 py-2 text-sm",
          large: "px-4 py-2 text-sm"
        }
      },
      defaults: {
        style: :primary,
        size: :small
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
