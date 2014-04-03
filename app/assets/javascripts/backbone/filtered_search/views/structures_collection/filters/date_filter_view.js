
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DateFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'date_filter_view',

        initialize: function() {
            this.data = {start_date: '', end_date: ''};
        },

        setup: function (data) {
            this.data    = data;
            // Re render to have the data in the view.
            this.render();

            this.populateHourRange(this.ui.$hour_range.find('select').first(), 0, 24);
            this.populateHourRange(this.ui.$hour_range.find('select').last(), 0, 24);
            this.ui.$week_days_select.val(data.week_days);
            this.ui.$date_range.hide();
            this.ui.$hour_range.hide();

            // If hours correspond to a value of the select, then select it,
            if (this.ui.$time_select.find('option[value=' + data.start_hour + '-' + data.end_hour + ']').length > 0) {
                this.ui.$time_select.val(data.start_hour + '-' + data.end_hour);
            // else show the time picker
            } else if (data.start_hour.length !== 0 || data.end_hour.length !== 0) {
                this.ui.$hour_range.show();
                this.$('#start-hour').val(data.start_hour);
                this.$('#end-hour').val(data.end_hour);
                this.ui.$time_select.val('choose-slot');
            }

            if (this.ui.$start_date.val().length > 0 || this.ui.$end_date.val().length > 0 ) {
                this.showDateRange();
            }
            this.announceBreadcrumbs();
        },

        ui: {
            '$week_days_select': '[data-type=day]',
            '$time':             '[data-type=time]',
            '$time_select':      '[data-type=time] select',
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
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        announceBreadcrumbs: function() {
            // Remove breadcrumb if all values are not set
            if ((this.ui.$week_days_select.val() === null) &&
                (this.ui.$start_date.val().length === 0) &&
                (this.ui.$end_date.val().length === 0) &&
                this.ui.$time_select.val() === 'all-day') {
                this.trigger("filter:breadcrumb:remove", {target: 'date'});
            } else {
                this.trigger("filter:breadcrumb:add", {target: 'date', title: this.breadcrumbTitle()});
            }
        },

        breadcrumbTitle: function() {
            var title = '',
                self  = this;
            if (this.ui.$week_days_select.val() !== null) {
                var week_days = [];
                _.each(this.ui.$week_days_select.val(), function(value) {
                    week_days.push(self.ui.$week_days_select.find('option[value=' + value + ']').text());
                });
                title += week_days.join(', ')
            }
            if (this.ui.$time_select.val() === 'all-day') {
                title += ' toute la journée';
            } else if (this.ui.$time_select.val() === 'choose-slot') {
                title += ' de ' + this.$el.find('#start-hour').val() + 'h'
                if (this.$el.find('#end-hour').val().length > 0) { title += ' à ' + this.$el.find('#end-hour').val() + 'h' }
            } else if (this.ui.$time_select.val() !== 'all-day') {
                title += ' / ' + this.ui.$time_select.find('option[value=' + this.ui.$time_select.val() + ']').text()
            }
            if (this.ui.$start_date.val().length !== 0 && this.ui.$end_date.val().length !== 0) {
                title += 'Du '+ this.ui.$start_date.val() + ' au ' + this.ui.$end_date.val()
            }
            return title;
        },

        announceDay: function () {
            this.trigger("filter:date", {
                'week_days[]'  : this.ui.$week_days_select.val(),
                start_date: null,
                end_date  : null
            });
            this.announceBreadcrumbs();
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        announceTime: function (e, data) {
            var range, data;
            switch(this.ui.$time.find('select').val()) {
                case 'choose-slot':
                    return;
                break;
                case 'all-day':
                    data = {start_hour: null, end_hour: null};
                break;
                default:
                    // Value is formatted as: 9-12
                    range = this.ui.$time.find('select').val().split('-');
                    data  = {
                        start_hour: range[0],
                        end_hour: range[1]
                    };
                break;
            }
            this.trigger("filter:date", data);
            this.announceBreadcrumbs();
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        announceHourRange: function (e) {
            if (this.ui.$time.find('select').val() !== "choose-slot") {
                return;
            }

            this.trigger("filter:date", {
                start_hour: this.$el.find('#start-hour').val(),
                end_hour:   this.$el.find('#end-hour').val(),
            });
            this.announceBreadcrumbs();
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

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
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

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
