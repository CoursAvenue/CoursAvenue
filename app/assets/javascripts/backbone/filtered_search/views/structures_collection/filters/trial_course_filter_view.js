
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.TrialCourseFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'trial_course_filter_view',

        setup: function (data) {
            if (data.trial_course_amount) {
                if (data.trial_course_amount == '0') {
                    this.ui.$free_trial_course_input.prop('checked', true);
                } else {
                    this.ui.$trial_course_price_select.val(data.trial_course_amount);
                }
            }
            this.announceBreadcrumb();
        },

        ui: {
            '$free_trial_course_input'  : '#free-trial-course',
            '$trial_course_price_select': '#trial-course-price'
        },

        events: {
            'change @ui.$free_trial_course_input':   'announce',
            'change @ui.$trial_course_price_select': 'announce',
            'click  @ui.$trial_course_price_select': 'deselectTrialRadio'
        },


        announce: function (e) {
            var trial_course_price;
            if (this.ui.$free_trial_course_input.is(':checked')) {
                trial_course_price = 0;
            } else {
                this.deselectTrialRadio();
                trial_course_price = this.ui.$trial_course_price_select.val();
            }
            this.trigger("filter:trial_course", {trial_course_amount: trial_course_price});
            this.announceBreadcrumb(trial_course_price);
        },

        announceBreadcrumb: function(trial_course_price) {
            if (!trial_course_price) {
                if (this.ui.$free_trial_course_input.is(':checked')) {
                    trial_course_price = 0;
                } else {
                    trial_course_price = this.ui.$trial_course_price_select.val();
                }
            }
            if (trial_course_price === '') {
                this.trigger("filter:breadcrumb:remove", {target: 'trial_course'});
            } else {
                this.trigger("filter:breadcrumb:add", {target: 'trial_course'});
            }
        },

        deselectTrialRadio: function() {
            this.ui.$free_trial_course_input.prop('checked', false);
        },

        // Clears all the given filters
        clear: function (filters) {
            this.ui.$free_trial_course_input.prop('checked', false);
            this.ui.$trial_course_price_select.val('');
            this.announce();
        }
    });
});
