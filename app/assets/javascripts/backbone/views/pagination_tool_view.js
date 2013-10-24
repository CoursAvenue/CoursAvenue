
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.PaginationToolView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/pagination_tool_view',

        /* data to describe the pagination tool */
        resetPaginationTool: function (data) {
            this.current_pagination_data = data;
            this.render();
        },

        serializeData: function (data) {
            return this.current_pagination_data;
        },

        /* the pagination tool forwards all events, since it has
        * no idea what it is paginating */
        events: {
            'click .pagination li.btn a[rel=next]': 'next',
            'click .pagination li.btn a[rel=prev]': 'prev',
            'click .pagination li.btn a[rel=page]': 'page',
        },

        next: function (e) {
            e.preventDefault();
            this.trigger('pagination:next', e);

            return false;
        },

        prev: function (e) {
            e.preventDefault();
            this.trigger('pagination:prev', e);

            return false;
        },

        page: function (e) {
            e.preventDefault();
            this.trigger('pagination:page', e);

            return false;
        },
    });

});
