class Submissions::FormBuilder < ActionView::Helpers::FormBuilder

  def text_field(attr, options = {})
    label = options.delete(:label)
    required = options.delete(:required)

    options[:class] ||= 'form-control'

    "".tap do |html|
      unless label == false
        html << label(attr, label, class: "#{'required' if required}")
      end
      html << super(attr, options)
    end.html_safe
  end

  def text_area(attr, options = {})
    label = options.delete(:label)
    required = options.delete(:required)

    options[:class] ||= 'form-control'

    "".tap do |html|
      unless label == false
        html << label(attr, label, class: "#{'required' if required}")
      end
      html << super(attr, options)
    end.html_safe
  end
end
