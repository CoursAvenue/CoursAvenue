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
            if (this.current_summary_data.city) {
                this.current_summary_data.city = this.current_summary_data.city.replace(', France', '');
            }
            return _.extend(this.current_summary_data, {
                // Clearly not the best, I know.
                subject_name: $('[data-type="subjects-breadcrumb"] li:last').text()
            });
        }

    });
});
