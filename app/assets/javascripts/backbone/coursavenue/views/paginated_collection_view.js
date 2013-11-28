
CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.PaginatedCollectionView = Module.AccordionView.extend({

        onAfterShow: function() {
            this.announcePaginatorUpdated();
        },

        /* VIRTUAL inheriting classes must override announcePaginatorUpdated */
        announcePaginatorUpdated: function () {
            throw "announcePaginatorUpdated is a virtual method. Override it in your inheriting class";
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
        *  - send enough information to be able to build the query strings over there
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
            /* however, if we reset it here the results will appear to "vanish" and re-appear */
            this.collection.setQuery(filters);

            /* we are updating from the location filter */
            if (filters.city && filters.lat) {
                this.trigger('filter:update:map', filters);
            }

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
            if (page == this.collection.currentPage) { return false };

            var self = this;

            self.trigger('paginator:updating', this);
            this.collection.goTo(page, {
                success: function () {
                    self.announcePaginatorUpdated();
                }
            });

            return false;
        },

        scrollToView: function(view) {
            var element = view.$el;

            this.$el.parents('section').scrollTo(element[0], {duration: 400});
        }
    });
});
