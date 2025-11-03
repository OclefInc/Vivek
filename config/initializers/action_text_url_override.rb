# Rails.application.config.to_prepare do
#   ActionText::Content.class_eval do
#     alias_method :original_to_html, :to_html

#     def to_html
#       html = original_to_html

#       # In development, replace production URLs with local URLs
#       if Rails.env.development?
#         html_string = html.respond_to?(:to_s) ? html.to_s : html
#         html = html_string.gsub("https://www.thevivekproject.com", "https://vivek.test")
#                           .gsub("https://thevivekproject.com", "https://vivek.test")
#         html = html.html_safe if html.respond_to?(:html_safe)
#       end

#       html
#     end
#   end
# end
