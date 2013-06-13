(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * data-start-time-wrapper: selector
     * data-end-time-wrapper: selector
     */

    objects.TimeRange = new Class({

        initialize: function(el, options) {
            this.start_wrapper          = el.getElements(el.get('data-start-time-wrapper'))[0];
            this.start_time_selects     = this.start_wrapper.getElements('select.time');
            this.end_wrapper            = el.getElements(el.get('data-end-time-wrapper'))[0];
            this.end_time_selects       = this.end_wrapper.getElements('select.time');
            this.getHourAndMinSelect();
            this.attachEvents();
        },

        getHourAndMinSelect: function() {
            this.start_time_selects.each(function(select) {
                if (select.get('name').contains('4i')) {
                    this.start_time_hour_select = select;
                } else if (select.get('name').contains('5i')) {
                    this.start_time_min_select = select;
                }
            }.bind(this));

            this.end_time_selects.each(function(select) {
                if (select.get('name').contains('4i')) {
                    this.end_time_hour_select = select;
                } else if (select.get('name').contains('5i')) {
                    this.end_time_min_select = select;
                }
            }.bind(this));

        },

        attachEvents: function() {
            this.start_time_hour_select.addEvent('change', function(select) {
                var start_hour_time = parseInt(select.target.get('value'));
                this.end_time_hour_select.set('value', start_hour_time + 1)
            }.bind(this));
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=time-range]').each(function(el) {
        new GLOBAL.Objects.TimeRange(el);
    });
});
