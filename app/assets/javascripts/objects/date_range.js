(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * data-start-date: CSS selector
     * data-end-date: CSS selector
     */

    objects.DateRange = new Class({

        initialize: function(el, options) {
            this.start_date  = el.getElements(el.get('data-start-date'))[0];
            this.end_date    = el.getElements(el.get('data-end-date'))[0];
            this.attachEvents();
        },

        attachEvents: function() {
            this.start_date.addEvent('change', function() {
                this.end_date.set('value', this.start_date.get('value'));
            }.bind(this));
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=date-range]').each(function(el) {
        new GLOBAL.Objects.DateRange(el);
    });
});
