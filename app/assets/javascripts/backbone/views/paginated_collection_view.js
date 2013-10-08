/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.PaginatedCollectionView = Backbone.Marionette.CompositeView.extend({
        template: 'backbone/templates/paginated_collection_view',
        itemView: FilteredSearch.Views.StructureView,
        itemViewContainer: 'ul.' + FilteredSearch.slug + '__list',

        /* transform the collection object's pagination data into a form
         * that can be digested by handlebars */
        serializeData: function(){
            console.log("PaginatedCollectionView->serializeData");
            var data = this.collection;
            var first_result = (data.currentPage - 1) * data.perPage + 1;

            return {
                current_page: data.currentPage,
                last_page: data.totalPages,
                first: first_result,
                last: Math.min(first_result + data.perPage - 1, data.grandTotal),
                total: data.grandTotal,
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

                if (self.canSkipPage(current_page, data)) { // 1, ..., 5, 6, 7, ..., 9
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

        /* ui controls for the pagination tool */
        events: {
            'click .pagination li.btn a[rel=next]': 'nextPage',
            'click .pagination li.btn a[rel=prev]': 'prevPage',
            'click .pagination li.btn a[rel=page]': 'goToPage',
            'click a[data-type=filter]': 'filterQuery'
        },

        /* simplistic implementation of general filters:
        * click on anything with data-type=filter and you
        * get results filtered by that */
        filterQuery: function(e) {
            e.preventDefault();

            var value = e.currentTarget.getAttribute('data-value');
            this.collection.setQuery({ sort: value });

            return this.changePage(this.collection.firstPage);
        },

        nextPage: function (e) {
            e.preventDefault();
            var page = Math.min(this.collection.currentPage + 1, this.collection.totalPages);

            return this.changePage(page);
        },

        prevPage: function (e) {
            e.preventDefault();
            var page = Math.max(this.collection.currentPage - 1, 1);

            return this.changePage(page);
        },

        goToPage: function (e) {
            e.preventDefault();
            var page = e.currentTarget.text;

            return this.changePage(page);
        },

        changePage: function (page) {
            if (page == this.collection.currentPage) return false;

            var self = this;

            this.collection.goTo(page, {
                success: function () {
                    console.log("EVENT  PaginatedCollection->changePage->success")
                    self.render();
                }
            });

            return false;
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        itemViewOptions: function(model, index) {
            console.log("PaginatedCollectionView->itemViewOptions");
            // we could pass some information from the collectionView
            return { };
        }
    });
});
