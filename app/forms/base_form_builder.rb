class BaseFormBuilder < ActionView::Helpers::FormBuilder
  def submit(value = nil, options = nil)
    value, options = nil, value if value.is_a?(Hash)
    value ||= submit_default_value
    @template.button_tag(value, options)
  end
end
