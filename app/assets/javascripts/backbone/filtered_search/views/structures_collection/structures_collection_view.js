/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

FilteredSearch.module('Views.StructuresCollection', function(Module, App, Backbone, Marionette, $, _) {
    var EmptyStrcutureList = Marionette.ItemView.extend({
        tagName: 'div',
        template: Module.templateDirname() + 'empty_structures_collection_view',

        events: {
          'click [data-behavior=zoom-out]': 'triggerZoomOut',
          'click [data-behavior=remove-filters]': 'triggerRemoveFilers',
        },

        triggerRemoveFilers: function  triggerRemoveFilers () {
            this.trigger('filters:remove:all');
        },

        triggerZoomOut: function  triggerZoomOut () {
            this.trigger('map:zoom:out');
        }
    });

    Module.StructuresCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        template: Module.templateDirname() + 'structures_collection_view',
        childView: Module.Structure.StructureView,
        childViewContainer: '.' + FilteredSearch.slug + '__list',
        className: 'relative',

        emptyView: EmptyStrcutureList,

        initialize: function initialize () {
            _.bindAll(this, 'initializeAddToFavoriteLinks', 'scrollToTop');
            CoursAvenue.on('user:signed:in', this.initializeAddToFavoriteLinks);
            this.on('pagination:changed', this.scrollToTop);
        },

        scrollToTop: function scrollToTop () {
            $.scrollTo(0, { easing: 'easeOutCubic', duration: 350 });
        },

        initializeAddToFavoriteLinks: function initializeAddToFavoriteLinks () {
            this.collection.each(function(model) {
                model.trigger('user:signed:in');
            });
        },

        onAfterShow: function onAfterShow () {
          this.announcePaginatorUpdated(true);
          var $sticky = $('[data-behavior=sticky]');
          $sticky.sticky({ offsetTop: 50,
                           z        : 1200,
                           oldWidth : true });
          this.renderSlideshows();
        },

        /* forward events with only the necessary data */
        onChildviewHighlighted: function onChildviewHighlighted (view, data) {
            this.trigger('structures:childview:highlighted', data);
        },

        onChildviewUnhighlighted: function onChildviewUnhighlighted (view, data) {
            this.trigger('structures:childview:unhighlighted', data);
        },

        onChildviewFiltersRemoveAll: function onChildviewFiltersRemoveAll () {
            this.trigger('filters:clear:all');
        },

        onChildviewMapZoomOut: function onChildviewMapZoomOut () {
            this.trigger('map:zoom:out');
        },

        /* WHOA so this event is actually getting the course:focus event
        *  via the broadcast method, not by having the childview actually
        *  trigger anything. Weird. */
        onChildviewCourseFocus: function onChildviewCourseFocus (view, data) {
            this.trigger('structures:childview:peacock', data);
        },


        findChildView: function findChildView (data) {
            /* find the first place that has any locations that match the given lat/lng */
            var position         = data.model.getLatLng();
            var $filters_wrapper = $('[data-el=filters-wrapper]')

            var relevant_structure = this.collection.findWhere({id: data.model.get('structure_id') })

            if (!relevant_structure) { return; }
            var childview = this.children.findByModel(relevant_structure);

            /* announce the view we found */
            this.trigger('structures:childview:found', { structure_view: childview, location_view: data } );
            $.scrollTo(childview.el, { duration: 400, offset: -($('header').first().outerHeight() + $filters_wrapper.outerHeight()) });

        },

        /* override inherited method */
        announcePaginatorUpdated: function announcePaginatorUpdated (is_first) {
            var state         = this.collection.state;
            var queryParams   = this.collection.queryParams;
            var first_result = (state.currentPage - 1) * state.perPage + 1;
            if (is_first !== true) {
                this.trigger('structures:updated', this.collection.map(function(structure) { return structure.get('id') } ));
            }

            /* announce the pagination statistics for the current page */
            this.trigger('structures:updated:pagination', {
                current_page:        state.currentPage,
                radius:              state.radius,
                last_page:           state.totalPages,
                query_strings:       this.buildPageQueriesForRange(state.totalPages),
                is_last_page:        this.collection.isLastPage(),
                is_first_page:       this.collection.isFirstPage(),
                next_query:          this.buildPageQueriesForRange(state.totalPages)[state.currentPage + 1],
                previous_query:      this.buildPageQueriesForRange(state.totalPages)[state.currentPage - 1]
            });

            /* announce the summary of the result set */
            this.trigger('structures:updated:summary', {
                first       : first_result,
                last        : Math.min(first_result + state.perPage - 1, state.grandTotal),
                total       : state.grandTotal,
                subject     : queryParams.subject_id,
                // We replace + by ' ' because space is replaced by a "+" in the query parameters on home page.
                city        : (queryParams.city ? queryParams.city.replace(/\+/g, ' ') : window.coursavenue.bootstrap.city_id),
            });

            this.trigger('structures:updated:query', { query: this.collection.getQuery().replace('?', '') }); // Removing the first '?' character
            /* announce the filters used in the current result set */
            this.trigger('map:update:zoom', {
                zoom: (queryParams.zoom ? queryParams.zoom : 12),
            });
            this.trigger('structures:updated:filter', {
                address_name         : (queryParams.address_name         ? queryParams.address_name.replace(/\+/g, ' ')       : ''),
                name                 : (queryParams.name                 ? queryParams.name                                 : ''),
                subject_id           : (queryParams.subject_id           ? queryParams.subject_id                           : ''),
                root_subject_id      : (queryParams.root_subject_id      ? queryParams.root_subject_id                      : ''),
                parent_subject_id    : (queryParams.parent_subject_id    ? queryParams.parent_subject_id                    : ''),
                level_ids            : (queryParams['level_ids[]']       ? _.ensureArray(queryParams['level_ids[]'])        : ''),
                audience_ids         : (queryParams['audience_ids[]']    ? _.ensureArray(queryParams['audience_ids[]'])     : ''),
                course_types         : (queryParams['course_types[]']    ? _.ensureArray(queryParams['course_types[]'])     : ''),
                min_age_for_kids     : (queryParams.min_age_for_kids     ? queryParams.min_age_for_kids                     : ''),
                max_age_for_kids     : (queryParams.max_age_for_kids     ? queryParams.max_age_for_kids                     : ''),
                price_type           : (queryParams.price_type           ? queryParams.price_type                           : ''),
                max_price            : (queryParams.max_price            ? queryParams.max_price                            : ''),
                min_price            : (queryParams.min_price            ? queryParams.min_price                            : ''),
                structure_types      : (queryParams['structure_types[]'] ? _.ensureArray(queryParams['structure_types[]'])  : ''),
                funding_type_ids     : (queryParams['funding_type_ids[]']? _.ensureArray(queryParams['funding_type_ids[]']) : ''),
                discount_types       : (queryParams['discount_types[]']  ? _.ensureArray(queryParams['discount_types[]'])   : ''),
                week_days            : (queryParams['week_days[]']       ? _.ensureArray(queryParams['week_days[]'])        : ''),
                start_date           : (queryParams.start_date           ? queryParams.start_date                           : ''),
                end_date             : (queryParams.end_date             ? queryParams.end_date                             : ''),
                start_hour           : (queryParams.start_hour           ? queryParams.start_hour                           : ''),
                end_hour             : (queryParams.end_hour             ? queryParams.end_hour                             : ''),
                is_open_for_trial    : (queryParams.is_open_for_trial    ? queryParams.is_open_for_trial                    : '')
            });

            this.trigger('structures:updated:maps');
        },

        structuresUpdated: function structuresUpdated (structure_ids) {
            this.logImpressions(structure_ids);
            this.renderSlideshows();
        },

        logImpressions: function logImpressions (structure_ids) {
            if (!window.coursavenue.bootstrap.current_pro_admin) {
                $.ajax({
                    type: "POST",
                    dataType: 'js',
                    url: Routes.statistics_path(),
                    data: {
                        action_type: 'impression',
                        fingerprint: $.cookie('fingerprint'),
                        structure_ids: structure_ids
                    }
                });
            }
        },

        renderSlideshows: function renderSlideshows () {
            var self = this;
            setTimeout(function(){
                // Start slideshow
                // Removing images and adding the image url to background image in order to have the image being covered
                self.$('.rslides img').each(function(){
                    var $this = $(this);
                    $this.closest('.media__item').hide();
                    $this.closest('li').css('background-image', 'url("' + $this.attr('src') + '")');
                });
                self.$(".rslides").responsiveSlides({
                    auto: false,
                    nav: true,
                    prevText: '<i class="alpha fa fa-chevron-left"></i>',
                    nextText: '<i class="alpha fa fa-chevron-right"></i>'
                });
                COURSAVENUE.initialize_fancy(self.$('.rslides-wrapper [data-behavior="fancy"]'));
            });
        },

        updateUrlAndFilter: function updateUrlAndFilter (data) {
            data.city = data.city || this.collection.queryParams.city || window.coursavenue.bootstrap.city_id;
            window.history.pushState('', '', CoursAvenue.searchPath(_.extend(this.collection.queryParams, data)));
            this.filterQuery(data);
        },

        childViewOptions: function childViewOptions () {
            var subject_name = $('[data-value="' + decodeURIComponent(this.collection.queryParams.subject_id) + '"]').first().text().trim();
            var search_term = this.collection.queryParams.name || "";

            return {
                search_term: decodeURIComponent(search_term),
                subject_name: subject_name
            }
        }

    });
});
