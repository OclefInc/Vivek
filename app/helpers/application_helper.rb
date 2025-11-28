module ApplicationHelper
  def nav_link_class(path_array)
    base_class = "block px-5 py-3"
    active_class = "bg-sky-200 dark:bg-gray-700 text-cyan-700 dark:text-cyan-400 font-semibold border-l-4 border-cyan-600 dark:border-cyan-500"
    inactive_class = "text-cyan-600 dark:text-cyan-400 hover:bg-sky-200 dark:hover:bg-gray-700 hover:text-cyan-500 dark:hover:text-cyan-300"

    if path_array.any? { |path|
      if path == "/admin" || path == "/admin/"
        request.path == "/admin" || request.path == "/admin/"
      else
        current_page?(path) || request.path.start_with?(path)
      end
    }
      "#{base_class} #{active_class}"
    else
      "#{base_class} #{inactive_class}"
    end
  end

  def user_avatar(user, size: 40)
    if user.avatar.attached?
      image_tag user.cropped_avatar(size: size), class: "rounded-full object-cover", style: "width: #{size}px; height: #{size}px;"
    elsif user.picture_url.present?
      image_tag user.picture_url, class: "rounded-full object-cover", style: "width: #{size}px; height: #{size}px;"
    else
      content_tag :div, user.initials, class: "rounded-full bg-indigo-500 text-white flex items-center justify-center text-xs font-bold", style: "width: #{size}px; height: #{size}px;"
    end
  end
end
