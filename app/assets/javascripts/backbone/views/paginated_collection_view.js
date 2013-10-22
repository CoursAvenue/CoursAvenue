/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {
    var EPSILON = 0.0000001; // google maps latlng precision

    Views.PaginatedCollectionView = Backbone.Marionette.CompositeView.extend({
        template: 'backbone/templates/paginated_collection_view',
        itemView: FilteredSearch.Views.StructureView,
        itemViewContainer: 'ul.' + FilteredSearch.slug + '__list',
        itemViewEventPrefix: 'paginator:itemview',

        /* forward events with only the necessary data */
        onPaginatorItemviewSelected: function (view, data) {
            this.trigger('paginator:structure:selected', data);
        },

        onPaginatorItemviewDeselected: function (view, data) {
            this.trigger('paginator:structure:deselected', data);
        },

        announcePaginatorUpdated: function () {
            var data = this.collection;
            var first_result = (data.currentPage - 1) * data.perPage + 1;

            /* the data is not used here */
            this.trigger('paginator:updated summary:updated', {
                current_page: data.currentPage,
                last_page: data.totalPages,
                first: first_result,
                last: Math.min(first_result + data.perPage - 1, data.grandTotal),
                total: data.grandTotal,
                buttons: this.buildPaginationButtons(data),
                previous_page_query: this.collection.previousQuery(),
                next_page_query: this.collection.nextQuery(),
                relevancy_query: this.collection.relevancyQuery(),
                popularity_query: this.collection.popularityQuery(),
                sort: this.collection.server_api.sort
            });

            this.trigger('paginator:updated:map', {
                lat: this.collection.server_api.lat,
                lng: this.collection.server_api.lng
            });
        },

        showLoader: function() {
            this.$loader.fadeIn({duration: 200});
        },

        hideLoader: function() {
            this.$loader.fadeOut({duration: 200});
        },

        onRender: function() {
            this.$loader = this.$('.filtered-search__loader');
        },

        onAfterShow: function () {
            console.log("PaginatedCollectionView->onAfterShow");
            this.announcePaginatorUpdated();
        },

        getPaginationInfo: function () {
            var data = this.collection;
            var first_result = (data.currentPage - 1) * data.perPage + 1;

            return {
                first: first_result,
                last: Math.min(first_result + data.perPage - 1, data.grandTotal),
                total: data.grandTotal,
                buttons: this.buildPaginationButtons(data)
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

        /* simplistic implementation of general filters:
        * click on anything with data-type=filter and you
        * get results filtered by that */
        /* TODO currently this method doesn't work on initial page load */
        filterQuery: function(filters) {
            console.log("EVENT  PaginatedCollectionView->filterQuery with");
            /* TODO check for redundancy: if the incoming filters don't
            *  change anything, we shouldn't do the update */
            // if (this.collection.setQuery(filter) === this.collection.getQuery()) {
            //     return false;
            // }

            /* since we are changing the query, we need to reset
            *  the collection, or else some elements will be in the wrong order */
            this.collection.reset();
            this.collection.setQuery(filters);

            // invalidate the 'currentPage' so that changePage will work
            // even if we are ALREADY on the first page...
            // TODO: this is a lame way
            this.collection.currentPage = -1;

            return this.changePage(this.collection.firstPage);
        },

        nextPage: function (e) {
            var page = Math.min(this.collection.currentPage + 1, this.collection.totalPages);

            return this.changePage(page);
        },

        prevPage: function (e) {
            var page = Math.max(this.collection.currentPage - 1, 1);

            return this.changePage(page);
        },

        goToPage: function (e) {
            var page = e.currentTarget.text;

            return this.changePage(page);
        },

        changePage: function (page) {
            if (page == this.collection.currentPage) return false;

            var self = this;

            self.trigger('paginator:updating', this);
            this.collection.goTo(page, {
                success: function () {
                    console.log("EVENT  PaginatedCollectionView->success");
                    self.announcePaginatorUpdated();
                }
            });

            return false;
        },

        zoomToStructure: function (data) {
            console.log("PaginatedCollectionView->zoomToStructure");

            /* find the first place that has any locations that match the given lat/lng */
            var position = data.model.getLatLng();

            var relevant_structure = this.collection.find(function (model) {

                return _.find(model.getRelation('places').related.models, function (place) {
                    var location = place.get('location');
                    var latlng = new google.maps.LatLng(location.latitude, location.longitude);

                    return (position.equals(latlng)); // ha! google to the rescue
                });
            });

            var course_element = this.children.findByModel(relevant_structure).$el;

            $(document.body).animate({scrollTop: course_element.offset().top}, 200,'easeInOutCubic');
            $(document.body).scrollTo(course_element[0], {duration: 400})
            // Unselect courses if there already are that are selected
            $('.course-element').removeClass('selected');
            setTimeout(function(){
                course_element.addClass('selected');
            }, 100);
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        itemViewOptions: function(model, index) {
            // we could pass some information from the collectionView
            return { };
        }
    });
});
