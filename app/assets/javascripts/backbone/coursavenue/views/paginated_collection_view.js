
CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.PaginatedCollectionView = Module.AccordionView.extend({

        onAfterShow: function() {
            this.announcePaginatorUpdated();
        },

        /* VIRTUAL inheriting classes must override announcePaginatorUpdated */
        announcePaginatorUpdated: function () {
            throw "announcePaginatorUpdated is a virtual method. Override it in your inheriting class";
        },

        /* given a natural range [1, x], returns a 1 indexed array of search queries for the collection
         * at the pages in the given range. */
        /* TODO this builds a huge array of strings all the time, and needs to get cached */
        buildPageQueriesForRange: function buildPageQueriesForRange (pages) {
            var results = [];

            _.times(pages, function (index) {
                // results array is 1 indexed
                results[index + 1] = this.collection.pageQuery(index + 1);

            }.bind(this));

            return results;
        },

        filterQuery: function(filters) {
            /* since we are changing the query, we need to reset
            *  the collection, or else some elements will be in the wrong order */
            /* however, if we reset it here the results will appear to "vanish" and re-appear */
            // TODO this problem has re-appeared in the usermanagement app
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

        refreshPage: function (e) {
            return this.changePage(this.collection.currentPage, { force: true });
        },

        changePage: function (page, options) {
            // normally we won't want to change to the current page
            // so we require a force option to be true
            if (page == this.collection.currentPage && !(options && options.force)) { return false };

            // if there is already a changePage method being resolved, abort it!
            if (this.gotoXHR && this.gotoXHR.readyState != 4) {
                this.gotoXHR.abort();
            }

            this.trigger('paginator:updating', this);

            this.gotoXHR = this.collection.goTo(page, {
                success: this.announcePaginatorUpdated.bind(this)
            });

            return false;
        },

        scrollToView: function(view) {
            var element = view.$el;
            this.$el.parents('section').scrollTo(element[0], { duration: 400, offset: -50 });
        }
    });
});
