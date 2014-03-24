
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
            'click [data-action=show-all-courses]': 'announceSummaryClicked'
        },

        announceSummaryClicked: function announceSummaryClicked (e) {
            e.preventDefault();
            // Don't announce if already been clicked and is disabled
            if (!this.$('[data-action=show-all-courses]').attr('disabled')) {
                this.trigger("summary:clicked");
                this.$('[data-action=show-all-courses]').attr('disabled', true);
            }
        }
    });
});
