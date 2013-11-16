FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.ResultsSummaryView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/results_summary_view',

        initialize: function (options) {
            this.current_summary_data = {};
        },

        /* data to describe the pagination tool */
        reset: function (data) {
            this.current_summary_data = data;
            if (data.sort !== undefined) {
                var method = data.sort === 'rating_desc';
                this.sort_by_popularity = method;
                this.sort_by_relevance = !method;
            } else {
                // Datas are sort by popularity by default
                this.sort_by_popularity = true;
            }

            this.render();
        },

        serializeData: function (data) {
            return _.extend(this.current_summary_data, {
                sort_by_popularity: this.sort_by_popularity,
                sort_by_relevance:  this.sort_by_relevance
            });
        },

        events: {
            'click a[data-type=filter]': 'filter'
        },

        filter: function (e) {
            e.preventDefault();

            var value = e.currentTarget.getAttribute('data-value');
            this.updateSortingMethod(e.currentTarget);
            this.trigger('filter:summary', { sort: value });

            return false;
        },

        updateSortingMethod: function (element) {
            var method = $(element).data('value') === 'rating_desc';
            this.sort_by_popularity = method;
            this.sort_by_relevance = !method;
        }
    });
});
