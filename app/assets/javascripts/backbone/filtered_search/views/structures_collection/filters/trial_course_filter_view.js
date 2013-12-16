
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.TrialCourseFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'trial_course_filter_view',

        setup: function (data) {
            var self = this;
            // var $input = this.$('[value=' + level_value + ']');
            // $input.prop('checked', true);
            // $input.parent('.btn').addClass('active');

            if (data.trial_course_amount) {

            }
            this.ui.$buttons.find('input[value=' + data.trial_course_amount + ']').prop('checked', true);
            this.announceBreadcrumb();
        },

        ui: {
            '$buttons': '[data-toggle=buttons]'
        },

        events: {
            'change input': 'announce'
        },


        announce: function (e, data) {
            var trial_course_amount
            this.trigger("filter:trial_course", { 'trial_course_amount': trial_course_amount });
            this.announceBreadcrumb(level_ids);
        },

        announceBreadcrumb: function(level_ids) {
            var title;
            level_ids = level_ids || _.map(this.$('[name="level_ids[]"]:checked'), function(input){ return input.value });
            if (level_ids.length === 0) {
                this.trigger("filter:breadcrumb:remove", {target: 'trial_course'});
            } else {
                title = _.map(this.$('[name="trial_course_price"]:checked'), function(input){ return $(input).parent().text().trim() });
                this.trigger("filter:breadcrumb:add", {target: 'trial_course', title: title.join(', ')});
            }
        },

        deselectTrialRadio: function() {
            this.ui.$free_trial_course_input.prop('checked', false);
        },

        // Clears all the given filters
        clear: function () {
            _.each(this.ui.$buttons.find('input'), function(input) {
                var $input = $(input);
                $input.prop("checked", false);
                $input.parent('.btn').removeClass('active');
            });
            this.announce();
        }
    });
});
