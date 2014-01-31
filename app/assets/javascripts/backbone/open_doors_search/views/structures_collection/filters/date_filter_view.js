
// TODO this will be done in the rebrand method
OpenDoorsSearch.Views.StructuresCollection.Filters.app = OpenDoorsSearch;

OpenDoorsSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DateFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'date_filter_view',
        initialize: function() {
            this.announce = _.debounce(this.announce, 800);
        },

        setup: function (data) {
            var self = this;
            _.each(data.week_days, function(week_day) {
                self.activateInput(week_day);
            });
            this.announceBreadcrumb();
        },

        // Clears all the given filters
        clear: function () {
            _.each(this.ui.$buttons.find('input'), function(input) {
                var $input = $(input);
                $input.prop("checked", false);
                $input.parent('.btn').removeClass('active');
            });
            this.announce();
        },

        ui: {
            '$buttons': '[data-toggle=buttons]'
        },

        events: {
            'change input': 'announce'
        },

        announce: function (e, data) {
            var week_days = _.map(this.$('[name="week_days[]"]:checked'), function(input){ return input.value });

            this.trigger("filter:date", {
                'week_days[]'  : week_days,
                start_date: null,
                end_date  : null
            });

            this.announceBreadcrumb(week_days);
        },

        announceBreadcrumb: function(week_days) {
            var title;
            week_days = week_days || _.map(this.$('[name="week_days[]"]:checked'), function(input){ return input.value });
            if (week_days.length === 0) {
                this.trigger("filter:breadcrumb:remove", {target: 'date'});
            } else {
                title = _.map(this.$('[name="week_days[]"]:checked'), function(input){ return $(input).parent().text().trim() });
                this.trigger("filter:breadcrumb:add", {target: 'date', title: this.breadcrumbTitle() });
            }
        },

        breadcrumbTitle: function () {
            return "date";
        },

        activateInput: function(week_day) {
             var $input = this.$('[value=' + week_day + ']');
            $input.prop('checked', true);
            $input.parent('.btn').addClass('active');
        }
    });
});

