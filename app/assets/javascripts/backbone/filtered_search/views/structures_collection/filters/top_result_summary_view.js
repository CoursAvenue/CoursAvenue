FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.TopResultsSummaryView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'top_results_summary_view',

        initialize: function initialize (options) {
            this.current_summary_data = {};
        },
        /* data to describe the pagination tool */
        reset: function reset (data) {
            this.current_summary_data = data;
            this.render();
        },

        serializeData: function serializeData (data) {
            var subject_name;
            if (this.current_summary_data.city) {
                this.current_summary_data.city = this.current_summary_data.city.replace(', France', '');
            }
            if ($('[data-type="subjects-breadcrumb"] li:last').text().length > 0) {
                subject_name = $('[data-type="subjects-breadcrumb"] li:last').text();
            } else if (window.coursavenue.bootstrap.subject_name) {
                subject_name = window.coursavenue.bootstrap.subject_name;
            }
            return _.extend(this.current_summary_data, {
                // Clearly not the best, I know.
                subject_name: subject_name
            });
        }

    });
});
