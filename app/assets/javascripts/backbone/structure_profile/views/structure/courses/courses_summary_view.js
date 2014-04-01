
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CoursesSummaryView = Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'courses_summary_view',

        initialize: function () {
            $(window).on("popstate", function (state) {
                // if popstate fires and the new state has a query string,
                // we should refresh the collections

                this.trigger("filter:popstate");

            }.bind(this));

        },

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
            if (this.removeFilterButtonIsEnabled()) {
                this.trigger("summary:clicked");

                // remove the URL query
                if (window.history.pushState) {
                    var url = window.location.pathname;
                    window.history.pushState({ }, null, url);
                }

                this.trigger("filter:removed");
                this.disableRemoveFilterButton();
            }
        },

        removeFilterButtonIsEnabled: function removeFilterButtonIsDisabled () {
            return !this.$('[data-action=show-all-courses]').attr('disabled');
        },

        disableRemoveFilterButton: function disableRemoveFilterButton () {
            this.$('[data-action=show-all-courses]').attr('disabled', true);
        },

        enableRemoveFilterButton: function enableRemoveFilterButton () {
            this.$('[data-action=show-all-courses]').attr('disabled', false);
        },

    });
});
