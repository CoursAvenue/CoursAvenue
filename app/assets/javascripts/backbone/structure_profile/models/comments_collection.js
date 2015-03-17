/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.CommentsCollection = CoursAvenue.Models.PaginatedCollection.extend({

        state: {
            firstPage:   1,
            perPage:     5,
            totalPages:  0,
            grandTotal:  0,
            radius:      2 // determines the behaviour of the ellipsis
        },

        url: function url () {
            return Routes.structure_comments_path(this.options.structure_id)
        },

        initialize: function initialize (models, options) {
            this.url              = Routes.structure_comments_path(options.structure_id)
            this.currentPage      = 1; // Always start at first page.
            this.queryParams      = this.queryParams || {};
            this.state.grandTotal = options.total_comments;
            this.state.totalPages = Math.ceil(this.state.grandTotal / this.state.perPage);
            this.getPage(1);
        },

        parse: function parse (response) {
            this.grandTotal = response.meta.total;
            this.totalPages = Math.ceil(response.meta.total / this.state.perPage);

            // Important to trigger reset on collection like Backbone does on collection
            // It is used on StructureProfile.js where `structure.get('comments') .on('reset',...`
            this.trigger('reset');
            return response.comments;
        }
    });
});
