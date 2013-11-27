/* Sets up the details specific to coursavenue's API */
/* TODO I think it should preload the next and previous pages */

CoursAvenue.module('Lib.Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.PaginatedCollection = Backbone.Paginator.requestPager.extend({

        paginator_ui: {
            firstPage:   1,
            perPage:     15,
            totalPages:  0,
            grandTotal:  0,
            radius:      2 // determines the behaviour of the ellipsis
        },

        previousQuery: function() {
            return this.pageQuery(this.paginator_ui.currentPage - 1);
        },

        nextQuery: function() {
            return this.pageQuery(this.paginator_ui.currentPage + 1);
        },

        currentQuery: function() {
            return this.pageQuery(this.paginator_ui.currentPage);
        },

        pageQuery: function(page) {
            return this.url.resource + this.getQuery({ 'page': page });
        },

        paginator_core: {
            type: 'GET',
            dataType: 'json',
            url: function() {
                return this.url.basename + this.url.resource + this.url.data_type;
            }
        }

    });
});
