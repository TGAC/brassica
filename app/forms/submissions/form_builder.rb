class Submissions::FormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper

  alias_method :default_text_field, :text_field
  alias_method :default_text_area, :text_area

  def text_field(attr, options = {})
    field_with_label_and_help(:text_field, attr, options.dup)
  end

  def text_area(attr, options = {})
    field_with_label_and_help(:text_area, attr, options.dup)
  end

  def field_with_label_and_help(field, attr, options = {})
    label = options.delete(:label)
    required = options.delete(:required)
    help = options.delete(:help)

    options[:class] ||= 'form-control'

    "".tap do |html|
      unless label == false
        html << label(attr, label, class: "#{'required' if required}")
      end
      html << send(:"default_#{field}", attr, options)
      if help
        html << content_tag(:small, help.html_safe, class: 'help-block')
      end
    end.html_safe
  end
end
