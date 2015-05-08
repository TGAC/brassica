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
      when 'data_tables'
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

  def api_props(key, interpolations = nil)
    props = I18n.t("api.#{key}")

    if interpolations
      props.each do |prop|
        interpolations.each do |var, val|
          prop[:desc] = prop[:desc].gsub(/%{#{var}}/, val.to_s)
        end
      end
    end

    props
  end
end
