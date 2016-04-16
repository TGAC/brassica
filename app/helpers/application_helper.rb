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
      when 'submissions'
        :submit
      when 'api_keys'
        :api
      else
        :home
    end
  end

  def active_link(label)
    content_tag :li, class: 'active' do
      link_to t("menu.#{label}"), '#'
    end
  end

  def navbar_menu
    {
      home: root_path,
      browse: browse_data_path,
      submit: new_submission_path,
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
    options[:other_content] ||= capture(&blk) if block_given?

    render partial: "/confirmable_action", locals: options.merge(label: label, object: object)
  end
end
