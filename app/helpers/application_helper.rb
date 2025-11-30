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

  def project_type_icon(project_type)
    case project_type.name
    when "Repertoire"
      # Musical Note
      raw '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-8 h-8">
        <path stroke-linecap="round" stroke-linejoin="round" d="M9 9l10.5-3m0 6.553v3.75a2.25 2.25 0 01-1.632 2.163l-1.32.377a1.803 1.803 0 11-.99-3.467l2.31-.66a2.25 2.25 0 001.632-2.163zm0 0V2.25L9 5.25v10.303m0 0v3.75a2.25 2.25 0 01-1.632 2.163l-1.32.377a1.803 1.803 0 01-.99-3.467l2.31-.66A2.25 2.25 0 009 15.553z" />
      </svg>'
    when "Standardized Test Preparation"
      # Academic Cap
      raw '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-8 h-8">
        <path stroke-linecap="round" stroke-linejoin="round" d="M4.26 10.147a60.436 60.436 0 00-.491 6.347A48.627 48.627 0 0112 20.904a48.627 48.627 0 018.232-4.41 60.46 60.46 0 00-.491-6.347m-15.482 0a50.57 50.57 0 00-2.658-.813A59.905 59.905 0 0112 3.493a59.902 59.902 0 0110.499 5.216 50.59 50.59 0 00-2.658.812m-15.482 0a50.697 50.697 0 0112.134 2.362 50.69 50.69 0 0112.134-2.362" />
      </svg>'
    when "Skill Development"
      # Chart Bar
      raw '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-8 h-8">
        <path stroke-linecap="round" stroke-linejoin="round" d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 013 19.875v-6.75zM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V8.625zM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V4.125z" />
      </svg>'
    when "Music Theory"
      # Treble Clef
      file_path = Rails.root.join("app", "assets", "images", "rickvanderzwet_Treble_clef_1.svg")
      if File.exist?(file_path)
        svg = File.read(file_path)
        # Make it colorable and size it
        svg.sub!(/<svg/, '<svg class="w-8 h-8"')
        svg.gsub!(/stroke="#000"/, 'stroke="currentColor" fill="currentColor"')
        raw svg
      else
        # Fallback if file not found
        raw '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-8 h-8">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 16.5a3 3 0 1 0 6 0 3 3 0 0 0-6 0m3-13.5v13.5m0-13.5a2.25 2.25 0 1 0 0 4.5 2.25 2.25 0 0 0 0-4.5m0 4.5a4.5 4.5 0 1 0 0 9 4.5 4.5 0 0 0 0-9" />
        </svg>'
      end
    when "Foundation Development"
      # Cube
      raw '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-8 h-8">
        <path stroke-linecap="round" stroke-linejoin="round" d="M21 7.5l-9-5.25L3 7.5m18 0l-9 5.25m9-5.25v9l-9 5.25M3 7.5l9 5.25M3 7.5v9l9 5.25m0-9v9" />
      </svg>'
    else
      raw '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-8 h-8">
        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" />
      </svg>'
    end
  end
end
