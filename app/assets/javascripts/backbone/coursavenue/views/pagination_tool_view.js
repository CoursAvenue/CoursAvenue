
CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.PaginationToolView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'pagination_tool_view',

        /* data to describe the pagination tool */
        reset: function (data) {
            data.buttons = this.buildPaginationButtons(data);

            this.current_pagination_data = data;
            this.render();
        },

        serializeData: function () {
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

        /* we want to show buttons for the first and last pages, and the
         * pages in a radius around the current page. So we will skip pages
         * that don't meet that criteria */
        canSkipPage: function (page, data) {
            var last_page = data.last_page,
                out_of_bounds = (data.current_page - data.radius > page || page > data.current_page + data.radius),
                bookend = (page == 1 || page == last_page);

            return (!bookend && out_of_bounds);
        },

        /* the query_strings are built in the paginated collection view */
        buildPaginationButtons: function (data) {
            var skipped = false,
                buttons = [];

            _.times(data.last_page, function(index) {
                var current_page = index + 1;

                debugger
                if (this.canSkipPage(current_page, data)) { // 1, ..., 5, 6, 7, ..., 9
                    skipped = true;
                } else {
                    if (skipped) { // push on an ellipsis if we've skipped any pages
                        buttons.push({ label: '...', disabled: true });
                    }

                    buttons.push({ // push the current page
                        label: current_page,
                        active: (current_page == data.current_page),
                        query: data.query_strings[current_page]
                    });

                    skipped = false;
                }
            }.bind(this));

            return buttons;
        },

    });

});
