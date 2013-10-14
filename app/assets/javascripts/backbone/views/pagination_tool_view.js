
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.PaginationToolView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/pagination_tool_view',

        /* data coming in from the paginated_collection_view */
        resetPaginationTool: function (data) {
            this.current_pagination_data = data;
            this.render();
        },

        serializeData: function (data) {
            return this.current_pagination_data;
        }
    });

});
