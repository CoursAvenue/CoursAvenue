/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.PaginatedCollectionView = Views.AccordionView.extend({
        template: 'backbone/templates/paginated_collection_view',
        itemView: FilteredSearch.Views.StructureView,
        itemViewContainer: 'ul.' + FilteredSearch.slug + '__list',
        className: 'filtered-search__list-wrapper',

        /* forward events with only the necessary data */
        onItemviewHighlighted: function (view, data) {
            this.trigger('structures:itemview:highlighted', data);
        },

        onItemviewUnhighlighted: function (view, data) {
            this.trigger('structures:itemview:unhighlighted', data);
        },

        onRender: function() {
            this.$loader = this.$('[data-type=loader]');
        },

        onAfterShow: function () {
            this.announcePaginatorUpdated();
        },

        onClickOutside: function (e) {
            // this event was not "outside" enough, the user was clicking on a review
            if (this.$itemViewContainer.find(e.originalEvent.explicitOriginalTarget).length !== 0) {
                return false;
            }

            // all accordions are closed
            if (this.currently_selected_cid === undefined) {
                return false;
            }

            var currently_selected = this.children.findByModelCid(this.currently_selected_cid);
            currently_selected.triggerMethod('click:outside');
        },

        announcePaginatorUpdated: function () {
            var data = this.collection;
            var first_result = (data.currentPage - 1) * data.perPage + 1;

            /* the data is not used here */
            this.trigger('structures:updated', {
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

            data = this.collection.getLatLngBounds();

            /* let the map know what we think the center and bounds should be */
            /* TODO this was used to center the map on page load, but I think
            *  now it is not being used */
            this.trigger('structures:updated:map', data);
        },

        showLoader: function() {
            var self = this;
            self.$loader.show();
            setTimeout(function(){
                self.$loader.addClass('visible');
            });
        },

        hideLoader: function() {
            var self = this;
            self.$loader.removeClass('visible');
            setTimeout(function(){
                self.$loader.hide();
            }, 300);
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

        /* TODO this method and canskippage should really be methods on the
        *  pagination tool. However, the tool needs the collection's Query
        *  method to construct query strings for anchors. This is a problem!
        *  we could:
        *  - build all the query strings and put them in an array
        *  - send a reference to the pageQuery method */
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

        filterQuery: function(filters) {
            /* TODO check for redundancy: if the incoming filters don't
            *  change anything, we shouldn't do the update */
            // if (this.collection.setQuery(filter) === this.collection.getQuery()) {
            //     return false;
            // }

            /* since we are changing the query, we need to reset
            *  the collection, or else some elements will be in the wrong order */
            this.collection.reset();
            this.collection.setQuery(filters);

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

            self.trigger('structures:updating', this);
            this.collection.goTo(page, {
                success: function () {
                    self.announcePaginatorUpdated();
                }
            });

            return false;
        },

        zoomToStructure: function (data) {
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
