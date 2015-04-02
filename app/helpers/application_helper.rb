module ApplicationHelper
  def active_nav_label
    case controller_name
      when 'application'
        case action_name
          when 'index'
            :home
          when 'about'
            :about
          else
            :home
        end
      when 'data_tables'
        :browse
      when 'submissions'
        :submit
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
    [
      [:home, root_path],
      [:browse, browse_data_path],
      [:submit, new_submission_path],
      [:api, '#'],
      [:about, about_path]
    ]
  end

  # Use this as the default main path for browsing UI section
  def browse_data_path
    data_tables_path(model: :plant_populations)
  end
end
