FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.ResultsSummaryView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/results_summary_view',
        sort_by_popularity: true,
        sort_by_relevance: false,

        initialize: function (options) {
            this.current_summary_data = {};
        },

        /* data to describe the pagination tool */
        resetSummaryTool: function (data) {
            console.log("ResultsSummaryView->resetSummaryTool");
            this.current_summary_data = data;
            this.updateSortingMethod();
            this.render();
        },

        serializeData: function (data) {
            return _.extend(this.current_summary_data, {
                sort_by_popularity: this.sort_by_popularity,
                sort_by_relevance: this.sort_by_relevance
            });
        },

        events: {
            'click a[data-type=filter]': 'filter'
        },

        filter: function (e) {
            console.log("ResultsSummaryView->filter");
            e.preventDefault();

            this.updateSortingMethod(e.currentTarget);
            this.trigger('summary:filter', e);

            return false;
        },

        updateSortingMethod: function (element) {
            var method = $(element).data('value') === 'rating_desc';
            this.sort_by_popularity = method;
            this.sort_by_relevance = !method;
        }
    });
});
