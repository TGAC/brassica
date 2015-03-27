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
      when 'plant_populations', 'plant_lines'
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
      [:browse, plant_populations_path],
      [:submit, new_submission_path],
      [:api, '#'],
      [:about, about_path]
    ]
  end
end
