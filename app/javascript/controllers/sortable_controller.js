import "jquery-ui"
(function ($) {

    $.fn.railsSortable = function (options) {
        options = options || {};
        var settings = $.extend({}, options);

        settings.baseUrl = settings.baseUrl || '';

        settings.update = function (event, ui) {
            if (typeof options.update === 'function') {
                options.update(event, ui);
            }

            $.ajax({
                type: 'POST',
                url: settings.baseUrl + '/sortable/reorder',
                dataType: 'json',
                contentType: 'application/json',
                data: JSON.stringify({
                    rails_sortable: $(this).sortable('toArray'),
                }),
            });
        }

        this.sortable(settings);
    };
})(jQuery);
import "jquery-ui-touch-punch"
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["tbody"]

    connect() {
        this.initSortable();
        // Start with sorting disabled
        $(this.tbodyTarget).sortable("disable");
    }

    initSortable() {
        $(this.tbodyTarget).railsSortable();
    }

    toggle(event) {
        if (event.target.checked) {
            $(this.tbodyTarget).sortable("enable");
        } else {
            $(this.tbodyTarget).sortable("disable");
        }
    }

    disconnect() {
        if ($(this.tbodyTarget).sortable("instance")) {
            $(this.tbodyTarget).sortable("destroy");
        }
    }
}
