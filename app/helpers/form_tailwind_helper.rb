module FormTailwindHelper
  def tw_form_with(**args, &)
    args.merge!({ builder: TailwindFormBuilder, ref: 'form' })

    form_with(**args, &)
  end
end
