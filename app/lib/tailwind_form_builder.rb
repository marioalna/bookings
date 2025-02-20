class TailwindFormBuilder < ActionView::Helpers::FormBuilder
  def float_text_input(name, *, &)
    float_input_element(:text_field, name, *, &)
  end

  def float_email_input(name, *, &)
    float_input_element(:email_field, name, *, &)
  end

  def float_password_input(name, *, &)
    float_input_element(:password_field, name, *, &)
  end

  def text_input(name, *, &)
    input_element(:text_field, name, *, &)
  end

  def area_input(name, *, &)
    input_element(:text_area, name, *, &)
  end

  def email_input(name, *, &)
    input_element(:email_field, name, *, &)
  end

  def password_input(name, *, &)
    input_element(:password_field, name, *, &)
  end

  def number_input(name, *, &)
    input_element(:number_field, name, *, &)
  end

  def file_input(name, *, &)
    input_element(:file_field, name, *, &)
  end

  def range_input(name, *, &)
    range_element(name, *, &)
  end

  def hidden_input(name, *, &)
    hidden_field(name, *, &)
  end

  def date_input(name, *, &)
    date_or_time_element(:date_field, name, *, &)
  end

  def time_input(name, *args, &)
    options = args.extract_options!
    options.merge!(step: 60)
    date_or_time_element(:time_field, name, options, &)
  end

  def datetime_input(name, *, &)
    datetime_element(:datetime_select, name, *, &)
  end

  def country_input(name, country_options = {}, html_options = {})
    html_options.merge!(class: "mt-2 shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md")
    country_select(name, country_options, html_options)
  end

  def fancy_radio_input(name, tag_value, *args, &block)
    options = args.extract_options!
    # message = options.fetch(:message, error_message(name))
    # error = options.fetch(:error, any_errors?(name))
    label_text = options.fetch(:label, name)
    description_text = options.fetch(:description, "")
    checked = options.fetch(:checked, false)
    active_label = checked ? "border-indigo-500 ring-2 ring-indigo-500" : ""
    checked_label = checked ? "border-transparent" : "border-gray-300"
    active_border = checked ? "border" : "border-2"
    checked_border = checked ? "border-indigo-500" : "border-transparent"

    # TODO: Extract this code to a component
    @template.content_tag(:div, { id: "field-#{name}" }) do
      @template.concat(
        label("#{name}_#{tag_value}",
              { class: "relative flex cursor-pointer rounded-lg border bg-white p-4 shadow-sm focus:outline-none #{active_label} #{checked_label}" }) do
          @template.concat(@template.content_tag(:span, { class: "flex flex-1" }) do
                             @template.concat(@template.content_tag(:span, { class: "flex flex-col" }) do
                                                @template.concat(@template.content_tag(:span,
                                                                                       class: "block text-sm font-medium text-gray-900") do
                                                                   label_text
                                                                 end)
                                                @template.concat(@template.content_tag(:span,
                                                                                       class: "mt-1 flex items-center text-sm text-gray-500") do
                                                                   description_text
                                                                 end)
                                                @template.concat(@template.content_tag(:span,
                                                                                       class: "mt-6 text-sm font-medium text-gray-900") do
                                                                   yield if block.present?
                                                                 end)
                                              end)
                           end)
          @template.concat(radio_button(name, tag_value))
          @template.concat(@template.content_tag(:span, "",
                                                 { class: "pointer-events-none absolute -inset-px rounded-lg #{checked_border} #{active_border}" }))
        end
      )
    end
  end

  def radio_input(name, tag_value, *args)
    options = args.extract_options!
    message = options.fetch(:message, error_message(name))
    error = options.fetch(:error, any_errors?(name))
    label_text = options.fetch(:label, name)
    label_class = options.fetch(:label_class, "")
    id = options.fetch(:id, "field-radio-#{tag_value}")

    @template.content_tag(:div, { class: "form-element pt-4", id: "field-#{name}" }) do
      @template.concat(@template.content_tag(:div, { class: "flex items-center" }) do
        @template.concat(radio_button(name, tag_value,
                                      { id:, class: "focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300" + (error ? " invalid-input" : "") }.merge(options)))
        @template.concat(label("#{name}_#{tag_value}", label_text,
                               { class: "ml-3 block text-sm font-medium text-gray-700 " + label_class + (error ? " invalid-label" : ""), for: id }))
      end)
      @template.concat(hint_message(message, error))
    end
  end

  def collection_select_input(name, collection, value_method, text_method, options = {}, html_options = {})
    message = html_options.fetch(:message, error_message(name))
    error = html_options.fetch(:error, any_errors?(name))
    style = html_options.fetch(:class, "")
    html_options.merge!(class: "shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md " + style)
    @template.content_tag(:div, { class: "form-element pt-1", id: "field-#{name}" }) do
      @template.concat(collection_select(name, collection, value_method, text_method, options, html_options))
      @template.concat(hint_message(message, error))
    end
  end

  def collection_time_select(name, options = {}, html_options = {})
    html_options.merge!(class: "shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm border-gray-300 rounded-md")
    time_select(name, options, html_options)
  end

  def check_input(name, *args)
    options = args.extract_options!
    message = options.fetch(:message, error_message(name))
    error = options.fetch(:error, any_errors?(name))
    label_text = options.fetch(:label, "")

    @template.content_tag(:div, { class: "form-element", id: "field-#{name}" }) do
      @template.concat(@template.content_tag(:div, { class: "flex items-center" }) do
        @template.concat(check_box(name,
                                   { class: "focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300 rounded" + (error ? " invalid-input" : "") }.merge(options), "true", "false"))
        @template.concat(label(name, label_text,
                               { class: "ml-3 text-sm font-medium text-gray-700" + (error ? " invalid-label" : "") }))
      end)
      @template.concat(hint_message(message, error))
    end
  end

  def submit_button(name, *args, &)
    args << { class: "inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md s hadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring -green-500" }
    button(name, *args, &)
  end

  private

    def input_element(field_type, name, *args, &block)
      options = args.extract_options!
      message = options.fetch(:message, error_message(name))
      error = options.fetch(:error, any_errors?(name))
      label_text = options.fetch(:label, name)
      styles = options.fetch(:styles, "")

      @template.content_tag(:div, { class: "form-element pt-4", id: "field-#{name}" }) do
        @template.concat(label(label_text,
                               { class: "text-sm font-medium text-gray-700" + (error ? " invalid-label" : "") }))
        @template.concat(@template.content_tag(:div, { class: "relative mt-1 rounded-md shadow-sm" }) do
          @template.concat(show_icon(block)) if block.present?
          @template.concat(send(field_type, name,
                                { class: "shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md " + styles + " " + (block.present? ? " pl-10" : "") + (error ? " invalid-input" : "") }.merge(options)))
          if error.present?
            @template.concat(@template.content_tag(:div,
                                                   { class: "pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3" }) do
                               @template.concat(@template.content_tag(:svg,
                                                                      { class: "h-5 w-5 text-red-500",
                                                                        viewBox: "0 0 20 20", fill: "currentColor" }) do
                                                  @template.concat(@template.content_tag(:path,
                                                                                         { 'fill-rule': "evenodd",
                                                                                           d: "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-5a.75.75 0 01.75.75v4.5a.75.75 0 01-1.5 0v-4.5A.75.75 0 0110 5zm0 10a1 1 0 100-2 1 1 0 000 2z", 'clip-rule': "evenodd" }) do
                                                                   end)
                                                end)
                             end)
          end
        end)
        @template.concat(hint_message(message, error))
      end
    end

    def float_input_element(field_type, name, *args)
      options = args.extract_options!
      message = options.fetch(:message, error_message(name))
      error = options.fetch(:error, any_errors?(name))
      label_text = options.fetch(:label, name)
      styles = options.fetch(:styles, "")

      @template.content_tag(:div, id: "field-#{name}") do
        @template.concat(@template.content_tag(:div, { class: "relative" }) do
          @template.concat(send(field_type, name,
                                { class: "block px-2.5 pb-2.5 pt-4 w-full text-sm text-gray-900 bg-transparent rounded-lg border-1 border-gray-300 appearance-none focus:outline-none focus:ring-0 focus:border-blue-600 peer" + styles + (error ? " invalid-float-input" : "") }.merge(options)))
          @template.concat(label(label_text,
                                 { class: "absolute text-sm text-gray-500 duration-300 transform -translate-y-4 scale-75 top-2 z-10 origin-[0] bg-white px-2 peer-focus:px-2 peer-focus:text-blue-600 peer-placeholder-shown:scale-100 peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2 peer-focus:top-2 peer-focus:scale-75 peer-focus:-translate-y-4 left-1" + (error ? " invalid-float-label" : "") }))
          @template.concat(hint_message(message, error))
          if error.present?
            @template.concat(@template.content_tag(:div,
                                                   { class: "pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3" }) do
                               @template.concat(@template.content_tag(:svg,
                                                                      { class: "h-5 w-5 text-red-500",
                                                                        viewBox: "0 0 20 20", fill: "currentColor" }) do
                                                  @template.concat(@template.content_tag(:path,
                                                                                         { 'fill-rule': "evenodd",
                                                                                           d: "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-5a.75.75 0 01.75.75v4.5a.75.75 0 01-1.5 0v-4.5A.75.75 0 0110 5zm0 10a1 1 0 100-2 1 1 0 000 2z", 'clip-rule': "evenodd" }) do
                                                                   end)
                                                end)
                             end)
          end
        end)
      end
    end

    def range_element(name, *args)
      options = args.extract_options!
      message = options.fetch(:message, error_message(name))
      error = options.fetch(:error, any_errors?(name))
      label_text = options.fetch(:label, name)

      @template.content_tag(:div, { class: "relative", id: "field-#{name}" }) do
        @template.concat(label(label_text, { class: "text-sm font-medium text-gray-700" }))
        @template.concat(
          range_field(
            name,
            {
              min: "0", max: "10", step: "1",
              class: "w-full h-2 mt-2 bg-blue-100 rounded-lg appearance-none cursor-pointer " + (error ? " invalid-input" : "")
            }.merge(options)
          )
        )
        @template.concat(hint_message(message, error))
      end
    end

    def date_or_time_element(field_type, name, *args, &block)
      options = args.extract_options!
      message = options.fetch(:message, error_message(name))
      error = options.fetch(:error, any_errors?(name))
      label_text = options.fetch(:label, name)

      @template.content_tag(:div, { class: "form-element pt-4", id: "field-#{name}" }) do
        @template.concat(label(label_text, { class: "text-sm font-medium text-gray-700" }))
        @template.concat(@template.content_tag(:div, { class: "relative mt-1" }) do
          @template.concat(show_icon(block)) if block.present?
          @template.concat(send(field_type, name,
                                { class: "shadow-sm block w-full focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm border-gray-300 rounded-md" + (block.present? ? " pl-10" : "") + (error ? " invalid-input" : "") }.merge(options)))
        end)
        @template.concat(hint_message(message, error))
      end
    end

    def datetime_element(field_type, name, *args, &block)
      options = args.extract_options!
      message = options.fetch(:message, error_message(name))
      error = options.fetch(:error, any_errors?(name))
      label_text = options.fetch(:label, name)

      @template.content_tag(:div, { class: "form-element pt-4", id: "field-#{name}" }) do
        @template.concat(label(label_text, { class: "text-sm font-medium text-gray-700" }))
        @template.concat(@template.content_tag(:div, { class: "relative mt-1" }) do
          @template.concat(show_icon(block)) if block.present?
          @template.concat(send(field_type, name, options,
                                { class: "shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm border-gray-300 rounded-md" + (block.present? ? " pl-10" : "") + (error ? " invalid-input" : "") }.merge(options)))
        end)
        @template.concat(hint_message(message, error))
      end
    end

    def show_icon(block)
      @template.content_tag(:span, { class: "absolute inset-y-0 left-0 pl-2 text-gray-600 flex items-center" }) do
        block.call
      end
    end

    def hint_message(message, error)
      return unless message.present?

      @template.content_tag(:span, class: "text-sm " + (error ? "hint-error" : "hint")) do
        message
      end
    end

    def error_message(name)
      return "" unless @object&.errors

      @object.errors[name].join(", ")
    end

    def any_errors?(name)
      return false unless @object&.errors

      @object.errors[name].any?
    end
end
