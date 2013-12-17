
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DateFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'date_filter_view',

        initialize: function() {
            this.data = {start_date: '', end_date: ''};
            this.announceDay       = _.debounce(this.announceDay, 700);
            this.announceTime      = _.debounce(this.announceTime, 700);
            this.announceHourRange = _.debounce(this.announceHourRange, 700);
            this.announceDateRange = _.debounce(this.announceDateRange, 700);
            this.announce          = _.debounce(this.announce, 700);
        },

        setup: function (data) {
            this.data    = data;
            // Re render to have the data in the view.
            this.render();

            this.populateHourRange(this.ui.$hour_range.find('select').first(), 0, 24);
            this.populateHourRange(this.ui.$hour_range.find('select').last(), 0, 24);
            this.ui.$hour_range.hide();
            this.ui.$date_range.hide();
            this.ui.$week_days_select.val(data.week_days);

            if (this.ui.$start_date.val().length > 0 || this.ui.$end_date.val().length > 0 ) {
                this.showDateRange();
            }
            this.announceBreadcrumbs();
        },

        ui: {
            '$week_days_select': '[data-type=day]',
            '$time':             '[data-type=time]',
            '$date':             '[data-type=date]',
            '$date_range':       '[data-type=date-range]',
            '$start_date':       '[data-value=start-date]',
            '$end_date':         '[data-value=end-date]',
            '$hour_range':       '[data-type=hour-range]'
        },

        events: {
            'click  [data-behaviour=toggle]':         'toggleModes',
            'change [data-type=day]':                 'announceDay',
            'change [data-type=time] select':         'announceTime',
            'change [data-type=time] > select':       'showHourRange',
            'change [data-type=hour-range] select':   'narrowHourRange',
            'change [data-type=hour-range] > select': 'announceHourRange',
            'change [data-type=date-range] input':    'announceDateRange'
        },

        /* TODO this creates three requests: would be better to gather the
        * json data and then make one request at the end. */
        announce: function () {
            this.announceDay();
            this.announceTime();
            this.announceHourRange();
        },

        announceDay: function () {
            this.trigger("filter:date", {
                'week_days[]'  : this.ui.$week_days_select.val(),
                start_date: null,
                end_date  : null
            });
            this.announceBreadcrumbs();
        },
        announceBreadcrumbs: function() {
            // Remove breadcrumb if all values are not set
            if ((this.ui.$week_days_select.val() === null) &&
                (this.ui.$start_date.val().length === 0) &&
                (this.ui.$end_date.val().length === 0) &&
                this.ui.$time.find('select').val() === 'all-day') {
                this.trigger("filter:breadcrumb:remove", {target: 'date'});
            } else {
                this.trigger("filter:breadcrumb:add", {target: 'date'});
            }
        },

        announceTime: function (e, data) {
            var range, data;
            switch(this.ui.$time.find('select').val()) {
                case 'choose-slot':
                    return;
                break;
                case 'all-day':
                    data = {start_hour: null, end_hour: null};
                break;
                case '9-12':
                case '12-14':
                case '14-18':
                case '18-23':
                    // Value is formatted as: 9-12
                    range = this.ui.$time.find('select').val().split('-');
                    data  = {
                        start_hour: range[0],
                        end_hour: range[1]
                    };
                break;
                default:
                    return;
                break;
            }
            this.trigger("filter:date", data);
            this.announceBreadcrumbs();
        },

        announceHourRange: function (e) {
            if (this.ui.$time.find('select').val() !== "choose-slot") {
                return;
            }

            this.trigger("filter:date", {
                start_hour: this.$el.find('#start-hour').val(),
                end_hour:   this.$el.find('#end-hour').val(),
            });
            this.announceBreadcrumbs();
        },

        /* TODO this announces many many times on each date change event */
        announceDateRange: function () {
            this.trigger("filter:date", {
                start_date:     (this.ui.$start_date.val().length > 0 ? this.ui.$start_date.val() : null),
                end_date:       (this.ui.$end_date.val().length > 0   ? this.ui.$end_date.val()   : null),
                start_hour:     null,
                'week_days[]':  null,
                end_hour:       null
            });
            this.announceBreadcrumbs();
        },

        showHourRange: function () {
            if (this.ui.$time.find('select').val() !== "choose-slot") {
                this.ui.$hour_range.slideUp();
                return;
            }

            this.ui.$hour_range.slideDown();

            if (this.$el.find('#start-hour').val() && this.$el.find('#end-hour').val()) {
                this.announceHourRange();
            } else {
                this.$el.find('#start-hour').val(8);
                this.$el.find('#end-hour').val(20);
            }
        },

        narrowHourRange: function (e) {
            var $select = this.ui.$hour_range.find('select:not(#' + e.currentTarget.id + ')'),
                val = e.currentTarget.value, min, max;

            if ($select.attr('id') !== 'start-hour') {
                min = parseInt(val, 10);
                max = 24;
            } else {
                min = 0;
                max = parseInt(val, 10) + 1; // the range is closed on top
            }

            this.populateHourRange($select, min, max);
        },

        populateHourRange: function ($select, min, max) {
            var val = parseInt($select.val(), 10) || 0;
            $select.empty();

            _.times((max - min), function (index) {
                $select.append('<option value="' + (index + min) + '">' + (index + min) + 'h' + '</option>')
            });

            // if the select value is still in [min, max), apply it
            if (min <= val && val < max) {
                $select.val(val);
            } else {
                ($select.attr('id') === 'start-hour')? $select.val(min) : $select.val(max);
            }
        },

        toggleModes: function () {
            if (this.ui.$date_range.is(':visible')) {
                this.showWeekDays();
                this.announce();
            } else {
                this.showDateRange();
                this.announceDateRange();
            }
        },

        showDateRange: function () {
            this.ui.$date_range.slideDown();
            this.ui.$date.slideUp();
        },

        showWeekDays: function () {
            this.ui.$date_range.slideUp();
            this.ui.$date.slideDown();
        },

        serializeData: function () {
            return {
                start_date: this.data.start_date,
                end_date:   this.data.end_date
            };
        },
        // Clears all the given filters
        clear: function () {
            this.ui.$week_days_select.val('').trigger('chosen:updated');
            this.ui.$start_date.val('');
            this.ui.$end_date.val('');
            this.ui.$time.find('select').val('all-day');
            this.announce();
        }
    });
});
