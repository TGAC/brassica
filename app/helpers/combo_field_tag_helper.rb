module ComboFieldTagHelper
  def combo_field_tag(name, value, option_tags = nil, options = {})
    select_placeholder = options[:select_placeholder] || "Select existing value"
    input_placeholder = options[:input_placeholder] || "Enter new value"
    klass = options[:class] || 'combo-field'

    unless options[:label] == false
      label_html = label_tag(options[:label] || name)
    end

    select_html = select_tag name, option_tags,
      prompt: '',
      class: "#{klass} form-control",
      data: { placeholder: select_placeholder }

    text_field_html = text_field_tag name, value,
      class: "form-control",
      placeholder: input_placeholder

    <<-HTML.html_safe
    <div class='combo-field-wrapper #{klass}-wrapper'>
      #{label_html}
      <div class='combo-field-select #{klass}-select'>#{select_html}</div>
      <div class='combo-field-alternative'>or</div>
      <div class='combo-field-input #{klass}-input'>
        #{text_field_html}
        <a href='#' class='clear-input hidden'>×</a>
      </div>
    </div>
    HTML
  end
end
