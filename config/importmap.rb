# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "local-time", to: "https://ga.jspm.io/npm:local-time@3.0.2/app/assets/javascripts/local-time.es2017-esm.js" # @3.0.3

pin "rails_sortable", to: "rails_sortable.js"
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.6.0/dist/jquery.js"
pin "jquery-ui", to: "https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"
pin "jquery-ui-touch-punch", to: "https://cdnjs.cloudflare.com/ajax/libs/jqueryui-touch-punch/0.2.3/jquery.ui.touch-punch.min.js"

pin "dropzone", to: "https://ga.jspm.io/npm:dropzone@5.7.2/dist/dropzone.js"
pin "@rails/activestorage", to: "activestorage.esm.js"

pin "tom-select", to: "https://ga.jspm.io/npm:tom-select@2.3.1/dist/esm/tom-select.complete.js"

pin "pdfjs-dist", to: "https://cdn.jsdelivr.net/npm/pdfjs-dist@3.11.174/build/pdf.min.js"

pin "plyr", to: "https://cdn.jsdelivr.net/npm/plyr@3.7.8/dist/plyr.min.js"
