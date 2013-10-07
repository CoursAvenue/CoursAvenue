/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.PaginatedCollectionView = Backbone.Marionette.CompositeView.extend({
        template: 'backbone/templates/paginated_collection_view',
        itemView: FilteredSearch.Views.StructureView,
        itemViewContainer: 'ul.' + FilteredSearch.slug + '__list',

        /* transform the paginator_ui object into a form that can be
        * digested by handlebars */
        serializeData: function(){
          console.log("PaginatedCollection->serializeData");
          var data = this.collection.paginator_ui;

          return {
            current_page: data.currentPage,
            last_page: data.totalPages,
            buttons: this.buildPaginationButtons(data),
            previous_page_query: this.collection.previousQuery(),
            next_page_query: this.collection.nextQuery(),
          };
        },

        /* we want to show buttons for the first and last pages, and the
        * pages in a radius around the current page. So we will skip pages
        * that don't meet that criteria */
        canSkipPage: function (page, data) {
          var last_page = data.totalPages,
              out_of_bounds = (data.currentPage - data.radius > page || page > data.currentPage + data.radius),
              bookend = (page == 1 || page == last_page);

          return (!bookend && out_of_bounds);
        },

        buildPaginationButtons: function (data) {
          var self = this,
              skipped = false,
              buttons = [];

          _.times(data.totalPages, function(index) {
            var current_page = index + 1;

            if (self.canSkipPage(current_page, data)) { // 1, 2, ..., 5, 6, ..., 9
              skipped = true;
            } else {
              if (skipped) { // push on an ellipsis if we've skipped any pages
                buttons.push({ label: '...', disabled: true });
              }

              buttons.push({ // push the current page
                label: current_page,
                active: (current_page == data.currentPage),
                query: self.collection.pageQuery(current_page)
              });

              skipped = false;
            }
          });

          return buttons;
        },

        events: {
          'click .pfaff': 'wat'
        },

        wat: function (e) {
          e.preventDefault();
          console.log("EVENT  PaginatedCollection->wat");

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
