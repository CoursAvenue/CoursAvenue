/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.CommentsCollection = CoursAvenue.Models.PaginatedCollection.extend({

        url: {
            data_type: '.json',
            basename: ''
        },

        initialize: function initialize (models, options) {
            this.url.resource             = Routes.structure_comments_path(options.structure_id);
            this.currentPage              = 1; // Always start at first page.
            this.server_api               = this.server_api || {};
            this.server_api.page = function () { return this.currentPage; }.bind(this);
            this.paginator_ui.currentPage = this.server_api.page();
            this.paginator_ui.perPage     = 5;
            this.paginator_ui.grandTotal  = (models.length === 0) ? 0 : options.total_comments;
            this.paginator_ui.totalPages  = Math.ceil(this.paginator_ui.grandTotal / this.paginator_ui.perPage);
            this.totalPages               = this.paginator_ui.totalPages;
        },

        parse: function(response) {
            this.grandTotal = response.meta.total;
            this.totalPages = Math.ceil(response.meta.total / this.paginator_ui.perPage);

            return response.comments;
        }
    });
});
