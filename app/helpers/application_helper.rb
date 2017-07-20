module ApplicationHelper
  def active_nav_label
    case controller_name
      when 'application'
        case action_name
          when 'index'
            :home
          when 'about'
            :about
          when 'api'
            :api
          else
            :home
        end
      when 'data_tables', 'trial_scorings'
        :browse
      when 'submissions', 'depositions'
        :submit
      when 'analyses'
        :analyze
      when 'api_keys'
        :api
      else
        :home
    end
  end

  def nav_item(label, path = "#", active: false, disabled: false, tab: nil)
    raise "Conflicting options" if active && disabled

    klass = active ? :active : (:disabled if disabled)
    link_options = tab ? { role: :tab, data: { toggle: :tab } } : {}
    path = "##{tab}" if tab

    content_tag :li, class: klass do
      link_to label, path, link_options
    end
  end

  def navbar_menu
    {
      home: root_path,
      browse: browse_data_path,
      submit: new_submission_path,
      analyze: new_analysis_path,
      api: api_documentation_path,
      about: about_path
    }
  end

  def api_props(title, key, interpolations = nil)
    props = I18n.t("api.#{key}")

    props.each do |prop|
      unless prop[:format]
        prop[:format] = I18n.t("api.default.attrs.#{prop[:name]}.format", default: 'string')
      end
      prop[:desc] = I18n.t("api.default.attrs.#{prop[:name]}.desc") unless prop[:desc]
      unless prop[:create]
        prop[:create] = I18n.t("api.default.attrs.#{prop[:name]}.create", default: '')
      end
    end

    if interpolations
      props.each do |prop|
        interpolations.each do |var, val|
          prop[:desc] = prop[:desc].gsub(/%{#{var}}/, val.to_s)
        end
      end
    end

    render partial: "application/api/props", locals: {
      title: title, props: props
    }
  end

  def confirmable_action(label, object, options = {}, &blk)
    options = options.dup
    options[:method] ||= :post
    options[:url] ||= url_for(object)
    options[:btn_class] ||= "btn-default"
    options[:btn_size] ||= ""
    options[:other_content] ||= capture(&blk) if block_given?
    options[:title] ||= nil

    render partial: "/confirmable_action", locals: options.merge(label: label, object: object)
  end

  def read_file(path, limit:)
    # Encoding is forced because text may be truncated in the middle of an individual character,
    # this may result in a visual glitch, but is not very important.
    File.open(path, "r") { |file| file.read(limit) }.force_encoding("UTF-8")
  end
end
