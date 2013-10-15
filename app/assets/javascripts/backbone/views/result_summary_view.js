FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.ResultsSummaryView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/results_summary_view',

        /* data to describe the pagination tool */
        resetSummaryTool: function (data) {
            this.current_summary_data = data;
            this.render();
        },

        serializeData: function (data) {
            return this.current_summary_data;
        },

        events: {
            'click a[data-type=filter]': 'filter'
        },

        filter: function (e) {
            e.preventDefault();
            this.trigger('summary:filter', e);

            return false;
        },

    });
});
