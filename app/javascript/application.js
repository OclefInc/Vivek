// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import "trix"
import "@rails/actiontext"

import jQuery from "jquery"
window.jQuery = jQuery // <- "select2" will check this
window.$ = jQuery

import LocalTime from "local-time"
LocalTime.start()
document.addEventListener("turbo:morph", () => {
    LocalTime.run()
})

