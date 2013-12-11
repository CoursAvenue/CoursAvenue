
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DateFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'date_filter_view',

        setup: function (data) {
            var $selects = this.ui.$hour_range.find('select');
            this.populateHourRange($selects, 0, 24);
            this.ui.$hour_range.hide();
            this.ui.$date_range.hide();

            if (data.date) {
                this.ui.$select.val(data.date);
            } else {
                this.ui.$start_date.val(data.start_date);
                this.ui.$end_date.val(data.end_date);
            }
        },

        ui: {
            '$day':          '[data-type=day]',
            '$time':         '[data-type=time]',
            '$date':         '[data-type=date]',
            '$date_range':   '[data-type=date-range]',
            '$start_date':   '[data-type=start-date]',
            '$end_date':     '[data-type=end-date]',
            '$hour_range':   '[data-time=hour-range]',
        },

        events: {
            'click [data-behaviour=toggle]':          'toggleModes',
            'change [data-type=day]':                 'announceDay',
            'change [data-type=time] select':         'announceTime',
            'change [data-type=time] > select':       'showHourRange',
            'change [data-time=hour-range] select':   'narrowHourRange',
            'change [data-time=hour-range] > select': 'announceHourRange',
            'change [data-type=date-range] input':    'announceDateRange',
        },

        serializeData: function(data) {
            return { 'days_of_the_week': $.fn.datepicker.dates.fr.days.slice(1) };
        },

        announceDay: function () {
            this.trigger("filter:day", { day: this.ui.$day.val() });
        },

        announceTime: function (e, data) {
            if (this.ui.$time.find('select').val() === "creneau") {
                return;
            }

            this.ui.$hour_range.slideUp();
            this.trigger("filter:time", {
                time: this.ui.$time.find('select').val(),
                start_time: null,
                end_time: null,
            });
        },

        announceHourRange: function (e) {
            this.trigger("filter:hour_range", {
                start_time: this.$el.find('#start-hour').val(),
                end_time: this.$el.find('#end-hour').val(),
                time: null // eliminate the time param
            });
        },

        announceDateRange: function () {
            this.trigger("filter:hour_range", {
                start_date: this.$el.find('#start-date').val(),
                end_date: this.$el.find('#end-date').val(),
                time: null, // eliminate the time param
                start_time: null,
                day: null,
                end_time: null
            });
        },

        showHourRange: function () {
            if (this.ui.$time.find('select').val() !== "creneau") {
                return;
            }

            this.ui.$hour_range.slideDown();

            if (this.$el.find('#start-hour').val() && this.$el.find('#end-hour').val()) {
                this.announceHourRange();
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
                $select.append('<option>' + (index + min) + 'H00' + '</option>')
            });

            // if the select value is still in [min, max), apply it
            if (min <= val && val < max) {
                $select.val(val + 'H00');
            } else {
                ($select.attr('id') === 'start-hour')? $select.val(min + 'H00') : $select.val(max + 'H00');
            }
        },

        toggleModes: function () {
            if (this.ui.$date_range.is(':visible')) {
                this.ui.$date_range.slideUp();
                this.ui.$date.slideDown();
            } else {
                this.ui.$date_range.slideDown();
                this.ui.$date.slideUp();
            }
        }

    });
});
