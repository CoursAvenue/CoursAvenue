
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.TrialCourseFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'trial_course_filter_view',

        setup: function (data) {
            var self = this;
            if (data.trial_course_amount === '20') {
                this.ui.$buttons.find('input[value=0]').prop('checked', true).parent('.btn').addClass('active');
            }
            if (data.trial_course_amount) {
                this.ui.$buttons.find('input[value=' + data.trial_course_amount + ']').prop('checked', true).parent('.btn').addClass('active');
            }
            this.announceBreadcrumb();
        },

        ui: {
            '$buttons': '[data-toggle=buttons]'
        },

        events: {
            'change input': 'announce'
        },


        announce: function (e, data) {
            var trial_course_amounts = _.map(this.ui.$buttons.find('[name="trial_course_amount"]:checked'), function(input){ return parseInt(input.value, 10) }),
                trial_course_amount  = trial_course_amounts.sort().reverse()[0];
            if (trial_course_amounts.length == 0) {
                this.trigger("filter:trial_course", { 'trial_course_amount': null });
                this.announceBreadcrumb(null);
            } else {
                this.trigger("filter:trial_course", { 'trial_course_amount': trial_course_amount });
                this.announceBreadcrumb(trial_course_amount);
            }
        },

        announceBreadcrumb: function(trial_course_amount) {
            if (!trial_course_amount) {
                var trial_course_amounts = _.map(this.ui.$buttons.find('[name="trial_course_amount"]:checked'), function(input){ return parseInt(input.value, 10) }),
                    trial_course_amount  = trial_course_amounts.sort().reverse()[0];
                if (trial_course_amounts.length == 0) { trial_course_amount = null }
            }
            if (trial_course_amount === null) {
                this.trigger("filter:breadcrumb:remove", {target: 'trial_course'});
            } else {
                this.trigger("filter:breadcrumb:add", {target: 'trial_course', title: this.titleFor(trial_course_amount)});
            }
        },

        titleFor: function(trial_course_amount) {
            switch(trial_course_amount) {
                case 0:
                    return 'Gratuit';
                break;
                case 20:
                    return 'de 0 à 20€';
                break;
                case 100:
                    return '+ de 20€';
                break;
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
