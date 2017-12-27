module Features
  module CommonHelpers
    def have_flash(type, msg)
      have_css(".flash-#{type}", text: msg)
    end

    def have_error(msg)
      have_css(".errors li", text: msg)
    end

    def have_link(text)
      have_css("a", text: text)
    end
  end
end
