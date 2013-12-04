/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

UserManagement.module('Views.UserProfilesCollection', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserProfilesCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        template: Module.templateDirname() + 'user_profiles_collection_view',
        itemView: Module.UserProfile.UserProfileView,
        itemViewContainer: '[data-type=container]',
        className: 'relative',

        /* forward events with only the necessary data */
        onItemviewHighlighted: function (view, data) {
            this.trigger('user_profiles:itemview:highlighted', data);
        },

        onItemviewUnhighlighted: function (view, data) {
            this.trigger('user_profiles:itemview:unhighlighted', data);
        },

        onItemviewCourseFocus: function (view, data) {
            this.trigger('user_profiles:itemview:peacock', data);
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        /* remember that itemViews are constructed and destroyed more often
        * than the corresponding models */
        itemViewOptions: function(model, index) {

            return { };
        },

        /* TODO we will need a method like this at some point */
        findItemView: function (data) {
            /* find the first place that has any locations that match the given criteria */

            /* announce the view we found */
            this.trigger('user_profiles:itemview:found', itemview);
            this.scrollToView(itemview);
        },

        /* override inherited method */
        announcePaginatorUpdated: function () {
            if (this.collection.totalPages == undefined || this.collection.totalPages < 1) {
                return;
            }

            var data         = this.collection;

            var first_result = (data.currentPage - 1) * data.perPage + 1;

            this.trigger('user_profiles:updated');

            /* announce the pagination statistics for the current page */
            this.trigger('user_profiles:updated:pagination', {
                current_page:        data.currentPage,
                last_page:           data.totalPages,
                buttons:             this.buildPaginationButtons(data),
                previous_page_query: this.collection.previousQuery(),
                next_page_query:     this.collection.nextQuery(),
                sort:                this.collection.server_api.sort
            });
        }
    });
});

