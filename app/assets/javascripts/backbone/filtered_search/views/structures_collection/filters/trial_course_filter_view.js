
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

   var ACTIVE_CLASS = 'btn--yellow';

    Module.TrialCourseFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'trial_course_filter_view',

        setup: function setup (data) {
            var self = this;
            if (data.is_open_for_trial) {
                this.ui.$button.prop('checked', true).parent('.btn').addClass(ACTIVE_CLASS);
            }
        },

        ui: {
            '$button': 'input'
        },

        events: {
            'change input': 'announce'
        },


        toggleClass: function toggleClass (argument) {
            if (this.ui.$button.prop('checked')) {
                this.ui.$button.parent('.btn').addClass(ACTIVE_CLASS)
            } else {
                this.ui.$button.parent('.btn').removeClass(ACTIVE_CLASS)
            }
        },

        announce: function announce (e, data) {
            this.toggleClass()
            var checked = this.ui.$button.is(':checked');
            if (checked) {
                this.trigger("filter:trial_course", { 'is_open_for_trial': true });
            } else {
                this.trigger("filter:trial_course", { 'is_open_for_trial': null });
            }
        },


        // Clears all the given filters
        clear: function clear () {
            _.each(this.ui.$buttons.find('input'), function(input) {
                var $input = $(input);
                $input.prop("checked", false);
                $input.parent('.btn').removeClass(ACTIVE_CLASS);
            });
            this.announce();
        }
    });
});
