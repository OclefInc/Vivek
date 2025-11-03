# https://stackoverflow.com/questions/61241745/cant-render-youtube-embed-iframe-with-rails-6-actiontext
# https://stackoverflow.com/a/66581494
tags = []
tags << "canvas"
tags << "iframe"
tags << "video"
tags << "input"
tags << "audio"
tags << "source"
tags << "embed"
tags << "div"
tags << "template"
tags << "time"
tags << "img"
tags << "turbo-cable-stream-source"
tags << "turbo-frame"
tags += [ "table", "thead", "th", "tbody", "tr", "td" ]

attributes = []
attributes << "style"
attributes << "controls"
attributes << "onclick"
attributes << "class"
attributes << "type"
attributes << "poster"
attributes << "preload"
attributes << "data-controller"
attributes << "data-url"
attributes << "data-blob-id"
attributes << "data-poster"
attributes << "data-turbo-frame"
attributes << "target"
attributes << "data-action"
attributes << "data-target"
attributes << "data-key"
attributes << "id"
attributes << "src"
attributes << "width"
attributes << "height"
attributes << "data-turbo-method"
attributes << "channel"
attributes << "signed-stream-name"
attributes << "connected"
attributes += [ "data-local", "title", "data-localized", "aria-label", "data-format" ]

ActionText::ContentHelper.singleton_class.class_eval do
  def allowed_tags
    @allowed_tags ||= Rails::Html::SafeListSanitizer.allowed_tags.to_a
  end

  def allowed_attributes
    @allowed_attributes ||= Rails::Html::SafeListSanitizer.allowed_attributes.to_a
  end
end

# If you need to allow specific attributes on these tags:
Rails::Html::SafeListSanitizer.allowed_tags += tags
Rails::Html::SafeListSanitizer.allowed_attributes += attributes

# For ActionText specifically (if you're using it):
ActionText::ContentHelper.allowed_tags += tags
ActionText::ContentHelper.allowed_attributes += attributes
