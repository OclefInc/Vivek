module ApplicationHelper
  def nav_link_class(path_array)
    base_class = "block px-5 py-3"
    active_class = "bg-sky-200 text-cyan-700 font-semibold border-l-4 border-cyan-600"
    inactive_class = "text-cyan-600 hover:bg-sky-200 hover:text-cyan-500"

    if path_array.any? { |path| current_page?(path) || request.path.start_with?(path) }
      "#{base_class} #{active_class}"
    else
      "#{base_class} #{inactive_class}"
    end
  end
end
