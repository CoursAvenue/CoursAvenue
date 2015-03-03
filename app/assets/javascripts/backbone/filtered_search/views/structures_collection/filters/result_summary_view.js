FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.ResultsSummaryView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'results_summary_view',
        className: 'nowrap',

        initialize: function initialize (options) {
            this.current_summary_data = {};
        },

        /* data to describe the pagination tool */
        reset: function reset (data) {
            this.current_summary_data = data;
            this.render();
        },

        serializeData: function serializeData (data) {
            return _.extend(this.current_summary_data, {
                sort_by_popularity: this.sort_by_popularity,
                sort_by_relevance:  this.sort_by_relevance
            });
        },

    });
});
