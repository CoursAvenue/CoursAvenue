
DiscoveryPassSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DateFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'date_filter_view',
        initialize: function() {
            this.announce     = _.debounce(this.announce, 800);
            this.announceTime = _.debounce(this.announceTime, 700);
        },

        setup: function (data) {
            var self = this;
            _.each(data.week_days, function(week_day) {
                self.activateInput(week_day);
            });
            this.populateHourRange(this.ui.$hour_range.find('select').first(), 0, 24);
            this.populateHourRange(this.ui.$hour_range.find('select').last(), 0, 24);
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

            this.announceBreadcrumbs();
        },

        // Clears all the given filters
        clear: function () {
            _.each(this.ui.$buttons.find('input'), function(input) {
                var $input = $(input);
                $input.prop("checked", false);
                $input.parent('.btn').removeClass('active');
            });
            this.ui.$time.find('select').val('all-day');
            this.announce();
        },

        ui: {
            '$buttons'    : '[data-toggle=buttons]',
            '$time'       : '[data-type=time]',
            '$time_select': '[data-type=time] select',
            '$hour_range':  '[data-type=hour-range]'
        },

        events: {
            'change input'     : 'announce',
            'change [data-type =time] select':         'announceTime',
            'change [data-type =time] > select':       'showHourRange',
            'change [data-type=time] > select':        'showHourRange',
            'change [data-type=hour-range] select':    'narrowHourRange',
            'change [data-type=hour-range] > select':  'announceHourRange'
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

        announce: function (e, data) {
            var week_days = _.map(this.$('[name="week_days[]"]:checked'), function(input){ return input.value });

            this.trigger("filter:date", {
                'week_days[]'  : week_days,
                start_date: null,
                end_date  : null
            });
            this.announceTime();
            this.announceHourRange();

            this.announceBreadcrumbs(week_days);
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

        announceBreadcrumbs: function(week_days) {
            var title;
            week_days = week_days || _.map(this.$('[name="week_days[]"]:checked'), function(input){ return input.value });
            if (week_days.length === 0 && this.ui.$time_select.val() === 'all-day') {
                this.trigger("filter:breadcrumb:remove", {target: 'date'});
            } else {
                title = _.map(this.$('[name="week_days[]"]:checked'), function(input){ return $(input).parent().text().trim() });
                this.trigger("filter:breadcrumb:add", {target: 'date', title: this.breadcrumbTitle() });
            }
        },

        breadcrumbTitle: function () {
            var title = '';
            if (this.ui.$buttons.find('input:checked')) {
                title = _.map(this.ui.$buttons.find('input:checked'), function(input) { return $(input).parent().text() }).join(', ');
            }
            if (this.ui.$time_select.val() === 'all-day') {
                title += ' toute la journée';
            } else if (this.ui.$time_select.val() === 'choose-slot') {
                title += ' de ' + this.$el.find('#start-hour').val() + 'h'
                if (this.$el.find('#end-hour').val().length > 0) { title += ' à ' + this.$el.find('#end-hour').val() + 'h' }
            } else if (this.ui.$time_select.val() !== 'all-day') {
                title += ' / ' + this.ui.$time_select.find('option[value=' + this.ui.$time_select.val() + ']').text()
            }
            return title;
        },

        activateInput: function(week_day) {
             var $input = this.$('[value=' + week_day + ']');
            $input.prop('checked', true);
            $input.parent('.btn').addClass('active');
        }
    });
});

