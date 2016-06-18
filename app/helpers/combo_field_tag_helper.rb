module ComboFieldTagHelper
  def combo_field_tag(name, value, option_tags = nil, options = {})
    select_placeholder = options[:select_placeholder] || "Select existing value"
    input_placeholder = options[:input_placeholder] || "Enter new value"
    id = options[:id]
    klass = options[:class] || 'combo-field'
    required = options[:required]
    help = options[:help]

    unless options[:label] == false
      label_html = label_tag(options[:label] || name, nil, class: "#{'required' if required}")
    end

    select_options = {
      prompt: '',
      class: "#{klass} form-control #{'required' if required}",
      data: { placeholder: select_placeholder }
    }
    select_options[:id] = "#{id}_select" if id.present?
    select_html = select_tag name, option_tags, select_options

    text_field_options = {
      class: "form-control",
      placeholder: input_placeholder
    }

    text_field_options[:id] = "#{id}_text" if id.present?
    text_field_html = text_field_tag name, value, text_field_options

    if help
      select_html << content_tag(:small, help.html_safe, class: 'help-block')
    end

    <<-HTML.html_safe
    <div class='combo-field-wrapper #{klass}-wrapper'>
      #{label_html}
      <div class='combo-field-select #{klass}-select'>#{select_html}</div>
      <div class='combo-field-alternative'>or</div>
      <div class='combo-field-input #{klass}-input'>
        #{text_field_html}
        <a href='#' class='clear-input hidden'>&times;</a>
      </div>
    </div>
    HTML
  end
end
