module FormStylesHelper
  def form_card_class
    class_variants(
      base: "bg-white shadow-sm rounded-lg",
      variants: {
        padding: {
          compact: "px-4 py-4 sm:px-6",
          normal: "px-4 py-5 sm:p-6",
          spacious: "p-6 sm:p-8"
        },
        width: {
          sm: "max-w-sm mx-auto",
          md: "max-w-md mx-auto",
          lg: "max-w-lg mx-auto",
          xl: "max-w-xl mx-auto",
          full: "w-full"
        }
      },
      defaults: {
        padding: :normal,
        width: :full
      }
    )
  end

  def form_title_class
    class_variants(
      base: "font-semibold leading-6 text-gray-900",
      variants: {
        size: {
          sm: "text-base",
          md: "text-lg",
          lg: "text-xl"
        }
      },
      defaults: {
        size: :md
      }
    )
  end

  def form_actions_class
    class_variants(
      base: "flex justify-between items-center border-t border-gray-200 pt-5 mt-8"
    )
  end

  def form_row_class
    class_variants(
      base: "grid gap-4",
      variants: {
        columns: {
          two: "sm:grid-cols-2",
          three: "sm:grid-cols-3"
        }
      },
      defaults: {
        columns: :two
      }
    )
  end
end
