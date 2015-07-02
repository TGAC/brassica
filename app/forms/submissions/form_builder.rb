class Submissions::FormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper

  def text_field(attr, options = {})
    label = options.delete(:label)
    required = options.delete(:required)
    help = options.delete(:help)

    options[:class] ||= 'form-control'

    "".tap do |html|
      unless label == false
        html << label(attr, label, class: "#{'required' if required}")
      end
      html << super(attr, options)
      if help
        html << content_tag(:small, help.html_safe, class: 'help-block')
      end
    end.html_safe
  end

  def text_area(attr, options = {})
    label = options.delete(:label)
    required = options.delete(:required)
    help = options.delete(:help)

    options[:class] ||= 'form-control'

    "".tap do |html|
      unless label == false
        html << label(attr, label, class: "#{'required' if required}")
      end
      html << super(attr, options)
      if help
        html << content_tag(:small, help, class: 'help-block')
      end
    end.html_safe
  end
end
