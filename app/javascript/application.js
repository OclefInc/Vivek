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
});

document.addEventListener("turbo:before-cache", () => {
    Array.from(document.getElementsByTagName('video')).forEach(video => video.removeAttribute('autoplay'));
});

window.getMetaValue = function(name) {
  const element = findElement(document.head, `meta[name="${name}"]`)
  if (element) {
    return element.getAttribute("content")
  }
}

window.findElement = function(root, selector) {
  if (typeof root == "string") {
    selector = root
    root = document
  }
  return root.querySelector(selector)
}

window.removeElement = function(el) {
  if (el && el.parentNode) {
    el.parentNode.removeChild(el);
  }
}

window.insertAfter =  function(el, referenceNode) {
    return referenceNode.parentNode.insertBefore(el, referenceNode.nextSibling);
}