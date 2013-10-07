/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.PaginatedCollectionView = Backbone.Marionette.CompositeView.extend({
        template: 'backbone/templates/paginated_collection_view',
        itemView: FilteredSearch.Views.StructureView,
        itemViewContainer: 'ul.' + FilteredSearch.slug + '__list',

        serializeData: function(){
          console.log("PaginatedCollection->serializeData");
          var data = this.collection.paginator_ui;
              last_page = data.totalPages;
              skipped = false;
              pages = [];

          var canSkip = function (page) {
            var out_of_bounds = (page < data.currentPage - 2 || page > data.currentPage + 2),
                bookend = (page == 1 || page == last_page);
            return (!bookend && out_of_bounds);
          }

          _.times(data.totalPages, function(index) {
            var current_page = index + 1;

            if (canSkip(current_page)) {
              skipped = true;
            } else {
              if (skipped) {
                pages.push({ body: '...', disabled: true });
              }

              pages.push({ body: current_page, active: (current_page == data.currentPage) });
              skipped = false;
            }
          });

          return {
            current_page: this.collection.paginator_ui.currentPage,
            last_page: this.collection.paginator_ui.totalPages,
            pages: pages
          };
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something */
        itemViewOptions: function(model, index) {
            console.log("PaginatedCollection->itemViewOptions");
            // we could pass some information from the collectionView
            return { };
        }
    });
});
