FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.CategoricalFilterView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/categorical_filter_view',

        resetCategoricalFilterTool: function () {

        }
    });
});
