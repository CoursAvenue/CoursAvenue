
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CoursesSummaryView = Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'courses_summary_view',

        serializeData: function () {

            return this.options;
        },

        ui: {
            '$summary': '[data-summary]',
        },

        events: {
            'click [data-action=show-all-courses]': 'announceFilterRemoved'
        },

        announceFilterRemoved: function announceSummaryClicked (e) {
            e.preventDefault();
            // Don't announce if already been clicked and is disabled
            if (!this.$('[data-action=show-all-courses]').attr('disabled')) {
                this.trigger("summary:clicked");

                // remove the URL query
                if (window.history.pushState) {
                    window.history.pushState({}, "", "");
                }

                this.trigger("filter:removed");
                this.$('[data-action=show-all-courses]').attr('disabled', true);
            }
        }
    });
});
