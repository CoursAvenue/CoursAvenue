FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.CategoricalFilterView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/categorical_filter_view',

        /* data to describe the pagination tool */
        resetCategoricalFilterTool: function (data) {
            this.current_summary_data = data;

            this.render();
        },

        serializeData: function (data) {
            return this.current_summary_data;
        },
    });
});
