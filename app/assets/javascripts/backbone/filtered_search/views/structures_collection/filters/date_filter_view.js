
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DateFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'date_filter_view',

        initialize: function initialize () {
            this.data = { start_date: '', end_date: '' };
        },

        setup: function setup (data) {
            this.data    = data;
            // Re render to have the data in the view.
            this.render();

            this.populateHourRange(this.ui.$hour_range.find('select').first(), 0, 24);
            this.populateHourRange(this.ui.$hour_range.find('select').last(), 0, 24);

            this.selectWeekDays(data.week_days);

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
            this.setButtonState();
        },

        ui: {
            '$week_days_inputs'    : '[data-type=day]',
            '$time'                : '[data-type=time]',
            '$time_select'         : '[data-type=time] select',
            '$date'                : '[data-type=date]',
            '$date_range'          : '[data-type=date-range]',
            '$start_date'          : '[data-value=start-date]',
            '$end_date'            : '[data-value=end-date]',
            '$hour_range'          : '[data-type=hour-range]',
            '$clear_filter_button' : '[data-behavior=clear-filter]',
            '$clearer'             : '[data-el=clearer]'
        },

        events: {
            'click  [data-behavior=toggle]'         : 'toggleModes',
            'change [data-type=day]'                : 'announceDay',
            'change [data-type=time] select'        : 'announceTime',
            'change [data-type=time] > select'      : 'showHourRange',
            'change [data-type=hour-range] select'  : 'narrowHourRange',
            'change [data-type=hour-range] > select': 'announceHourRange',
            'change [data-type=date-range] input'   : 'announceDateRange',
            'click @ui.$clear_filter_button'        : 'clear'
        },

        // this creates several requests, but only the most current one will
        // actually be processed, since the structures_collection_view cancels
        // out of date requests.
        announce: function announce () {
            this.announceDay();
            this.announceTime();
            this.announceHourRange();
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        /*
         * Set the state of the button, wether or not there are filters or not
         */
        setButtonState: function setButtonState () {
            if (this.weekDaysVal().length == 0 &&
                this.ui.$start_date.val().length == 0 &&
                this.ui.$end_date.val().length == 0 &&
                this.ui.$time_select.val() == 'all-day') {
                this.ui.$clear_filter_button.addClass('btn--gray')
                this.ui.$clearer.hide();
            } else {
                this.ui.$clearer.show();
                this.ui.$clear_filter_button.removeClass('btn--gray');
            }
        },

        announceDay: function announceDay () {
            this.trigger("filter:date", {
                'week_days[]': this.weekDaysVal(),
                start_date   : null,
                end_date     : null
            });
            this.setButtonState();
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        announceTime: function announceTime (e, data) {
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
            this.setButtonState();
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        announceHourRange: function announceHourRange (e) {
            if (this.ui.$time.find('select').val() !== "choose-slot") {
                return;
            }

            this.trigger("filter:date", {
                start_hour: this.$el.find('#start-hour').val(),
                end_hour:   this.$el.find('#end-hour').val(),
            });
            this.setButtonState();
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        /* this method is called any time the datepicker closes. So that's too
         * often, but there really isn't much we can do about it.
         * see card #314 [https://trello.com/c/KlTOIsZp] */
        announceDateRange: function announceDateRange () {
            this.trigger("filter:date", {
                start_date:     (this.ui.$start_date.val().length > 0 ? this.ui.$start_date.val() : null),
                end_date:       (this.ui.$end_date.val().length > 0   ? this.ui.$end_date.val()   : null),
                start_hour:     null,
                'week_days[]':  null,
                end_hour:       null
            });
            this.setButtonState();
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        showHourRange: function showHourRange () {
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

        narrowHourRange: function narrowHourRange (e) {
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

        populateHourRange: function populateHourRange ($select, min, max) {
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

        toggleModes: function toggleModes () {
            if (this.ui.$date_range.is(':visible')) {
                this.showWeekDays();
                this.announce();
            } else {
                this.showDateRange();
                this.announceDateRange();
            }
        },

        showDateRange: function showDateRange () {
            this.ui.$date_range.slideDown();
            // this.ui.$date.slideUp();
        },

        showWeekDays: function showWeekDays () {
            this.ui.$date_range.slideUp();
            // this.ui.$date.slideDown();
        },

        serializeData: function serializeData () {
            return {
                start_date: this.data.start_date,
                end_date:   this.data.end_date
            };
        },

        weekDaysVal: function weekDaysVal () {
            return _.map(this.ui.$week_days_inputs.filter(':checked'), function(input){ return input.value });
        },

        selectWeekDays: function selectWeekDays (week_days) {
            _.each(this.ui.$week_days_inputs, function(input) {
                var $input = $(input);
                if (parseInt($input.val(), 10) == parseInt(week_days, 10)) {
                    $input.prop("checked", true);
                    $input.parent('.btn').addClass('active');
                }
            });
        },

        // Clears all the given filters
        clear: function clear () {
            _.each(this.ui.$week_days_inputs, function(input) {
                var $input = $(input);
                $input.prop("checked", false);
                $input.parent('.btn').removeClass('active');
            });
            this.ui.$start_date.val('');
            this.ui.$end_date.val('');
            this.ui.$time.find('select').val('all-day');
            this.announce();
            this.setButtonState();
        }
    });
});
