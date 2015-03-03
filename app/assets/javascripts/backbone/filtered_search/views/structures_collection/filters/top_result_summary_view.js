FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.TopResultsSummaryView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'top_results_summary_view',

        initialize: function initialize (options) {
            this.current_summary_data = {
                subject_name: window.coursavenue.bootstrap.subject_name
            };
        },
        // Update current stored data
        reset: function reset (data) {
            _.extend(this.current_summary_data, data);
            this.render();
        },

        updateSubjectName: function updateSubjectName (data) {
            this.current_summary_data.subject_name = data.subject_name;
            this.render();
        },

        serializeData: function serializeData (data) {
            var subject_name;
            if (this.current_summary_data.city) {
                this.current_summary_data.city = this.current_summary_data.city.replace(', France', '');
            }
            return this.current_summary_data;
        }

    });
});
