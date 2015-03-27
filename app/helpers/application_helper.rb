module ApplicationHelper
  def active_nav_label
    case controller_name
      when 'application'
        case action_name
          when 'index'
            'Home'
          when 'about'
            'About us'
          else
            'Home'
        end
      when 'plant_populations', 'plant_lines'
        'Browse database'
      when 'submissions'
        'Submit data'
      else
        'Home'
    end
  end

  def active_link(label)
    content_tag :li, class: 'active' do
      link_to label, '#'
    end
  end

  def navbar_menu
    [
      ['Home', root_path],
      ['Browse database', plant_populations_path],
      ['Submit data', new_submission_path],
      ['API documentation', '#'],
      ['About us', about_path]
    ]
  end
end
