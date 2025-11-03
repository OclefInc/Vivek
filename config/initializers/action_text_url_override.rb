Rails.application.config.to_prepare do
  ActionText::Content.class_eval do
    alias_method :original_to_html, :to_html

    def to_html
      html = original_to_html

      # In development, replace production URLs with local URLs
      if Rails.env.development?
        html = html.to_s.gsub("https://www.thevivekproject.com", "https://vivek.test")
                       .gsub("https://thevivekproject.com", "https://vivek.test").html_safe
      end

      html
    end

    alias_method :to_s, :to_html
  end
end
