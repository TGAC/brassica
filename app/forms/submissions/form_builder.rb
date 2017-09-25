class Submissions::FormBuilder < BaseFormBuilder
  def combo_field(attr, option_tags, options = {})
    if attr.to_s =~ /\[\]\z/
      attr = attr[0...-2]
      name = "submission[content][#{attr}][]"
      id = "#{@object_name}_#{attr}_#{options.fetch(:idx)}"
    else
      name = "submission[content][#{attr}]"
    end
    value = options.has_key?(:value) ? options[:value] : @object.send(attr)
    label = options[:label] || attr.to_s.humanize
    required = options[:required]
    help = options[:help]
    options = {
      label: label,
      class: attr.to_s.dasherize,
      select_placeholder: "Select existing #{label.downcase}",
      input_placeholder: "Enter new #{label.downcase}",
      required: required,
      help: help
    }

    options.merge!(id: id) if id.present?

    html = @template.combo_field_tag(name, value, option_tags, options)

    @object.errors[attr].present? ? @template.field_error_proc.call(html) : html
  end
end
