
/* just a basic backbone model */
UserManagement.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.UserProfilesCollection = CoursAvenue.Models.PaginatedCollection.extend({
        model: Models.UserProfile,

        initialize: function (models, options) {
            var self = this;
            // define the server API based on the load-time URI
            this.server_api = this.makeOptionsFromSearch(window.location.search);
            this.currentPage = 1; // we always start from page 1
            this.server_api.page = function () { return self.currentPage; };

            /* we need to reset the collection on 'sync', rather than in the
             * paginated_collection_view. This is because we don't want a momentary
             * flash of the zero result set.
            *  However, the 'sync' event occurs too often, so we have to be sure
            *  that we are responding to both a sync and a filter, rather than
            *  just a sync */
            /* for now we will "detect" filters by the page being 1 */
            this.on('sync', function(model, response, xhr){
                if (model.currentPage === 1) {
                    this.reset(response.structures);
                }
            });

            // now write back the server_api so that the search bar is up to date
            // we are passing this.server_api for fun! ^o^ why not?
            if (window.history.pushState) { window.history.pushState({}, "Search Results", this.getQuery()); }

            this.paginator_ui.currentPage = this.server_api.page();

            /* TODO the results total seems to be out of sync with what we actually
             * receive, so for now we will just do this: */
            // this.paginator_ui.grandTotal  = (models.length === 0) ? 0 : options.total;
           // this.paginator_ui.totalPages  = Math.ceil(this.paginator_ui.grandTotal / this.paginator_ui.perPage);
            this.url.basename         = window.location.toString().split('/');
            this.url.basename.pop();
            this.url.basename         = this.url.basename.join('/');
        },

        /* where we can expect to find the resource we seek
         *  TODO this needs to be set on the server side */
        url: {
            resource: '/mes-eleves',
            data_type: '.json'
        },

//      url: function () {
//          console.log("UserProfilesCollection->url");

//          return "mes-eleves.json";
//      }
    });
});
