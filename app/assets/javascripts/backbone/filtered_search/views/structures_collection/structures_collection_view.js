/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

FilteredSearch.module('Views.StructuresCollection', function(Module, App, Backbone, Marionette, $, _) {
    var EmptyStrcutureList = Marionette.ItemView.extend({
        tagName: 'div',
        template: Module.templateDirname() + 'empty_structures_collection_view',

        initialize: function initialize (options) {
            this.search_term  = options.search_term;
            this.subject_name = options.subject_name;
        },

        serializeData: function serializeData () {
            return {
                search_term: this.search_term,
                subject_name: this.subject_name
            }
        }

    });

    Module.StructuresCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        template: Module.templateDirname() + 'structures_collection_view',
        itemView: Module.Structure.StructureView,
        itemViewContainer: '.' + FilteredSearch.slug + '__list',
        className: 'relative',

        emptyView: EmptyStrcutureList,

        initialize: function initialize () {
            window.onresize = this.resize_thumbnails;
            _.bindAll(this, 'initializeAddToFavoriteLinks');
            CoursAvenue.on('user:signed:in', this.initializeAddToFavoriteLinks);
        },

        initializeAddToFavoriteLinks: function initializeAddToFavoriteLinks () {
            this.collection.each(function(model) {
                model.trigger('user:signed:in');
            });
        },

        resize_thumbnails: function resize_thumbnails () {
            $('[data-resizeable-height]').css('height', $('[data-resizeable-height]').first().width() * 2 / 3);
        },

        onAfterShow: function onAfterShow () {
          this.announcePaginatorUpdated();
          var $sticky = $('[data-behavior=sticky]');
          $sticky.sticky({ scrollContainer: '.filtered-search__list-wrapper',
                           z: 1200,
                           oldWidth: true,
                           onStick: function() {
                              $sticky.css({ top: '50px', paddingTop: '8px' }).addClass('bg-white');
                           } });
        },
        /* forward events with only the necessary data */
        onItemviewHighlighted: function onItemviewHighlighted (view, data) {
            this.trigger('structures:itemview:highlighted', data);
        },

        onItemviewUnhighlighted: function onItemviewUnhighlighted (view, data) {
            this.trigger('structures:itemview:unhighlighted', data);
        },

        /* WHOA so this event is actually getting the course:focus event
        *  via the broadcast method, not by having the itemview actually
        *  trigger anything. Weird. */
        onItemviewCourseFocus: function onItemviewCourseFocus (view, data) {
            this.trigger('structures:itemview:peacock', data);
        },


        findItemView: function findItemView (data) {
            /* find the first place that has any locations that match the given lat/lng */
            var position = data.model.getLatLng();

            var relevant_structure = this.collection.find(function (model) {

                return _.find(model.getRelation('places').related.models, function (place) {
                    var latlng = new google.maps.LatLng(place.get('latitude'), place.get('longitude'));
                    return (position.equals(latlng)); // ha! google to the rescue
                });
            });

            var itemview = this.children.findByModel(relevant_structure);

            /* announce the view we found */
            this.trigger('structures:itemview:found', { structure_view: itemview, location_view: data } );
            this.scrollToView(itemview);

        },

        /* override inherited method */
        announcePaginatorUpdated: function announcePaginatorUpdated () {
            var data         = this.collection;
            var first_result = (data.currentPage - 1) * data.perPage + 1;

            this.trigger('structures:updated', data.map(function(structure) {return structure.get('id')}));

            /* announce the pagination statistics for the current page */
            this.trigger('structures:updated:pagination', {
                current_page:        data.currentPage,
                radius:              data.radius,
                last_page:           data.totalPages,
                query_strings:       this.buildPageQueriesForRange(data.totalPages),
                previous_page_query: this.collection.previousQuery(),
                next_page_query:     this.collection.nextQuery()
            });

            /* announce the summary of the result set */
            this.trigger('structures:updated:summary', {
                first: first_result,
                last: Math.min(first_result + data.perPage - 1, data.grandTotal),
                total: data.grandTotal
            });

            this.trigger('structures:updated:query', { query: this.collection.getQuery().replace('?', '') }); // Removing the first '?' character
            /* announce the filters used in the current result set */
            this.trigger('map:update:zoom', {
                zoom: (data.server_api.zoom ? data.server_api.zoom : 12),
            });
            this.trigger('structures:updated:filter', {
                address_name         : (data.server_api.address_name         ? data.server_api.address_name                         : ''),
                name                 : (data.server_api.name                 ? data.server_api.name                                 : ''),
                subject_id           : (data.server_api.subject_id           ? data.server_api.subject_id                           : ''),
                root_subject_id      : (data.server_api.root_subject_id      ? data.server_api.root_subject_id                      : ''),
                parent_subject_id    : (data.server_api.parent_subject_id    ? data.server_api.parent_subject_id                    : ''),
                level_ids            : (data.server_api['level_ids[]']       ? _.ensureArray(data.server_api['level_ids[]'])        : ''),
                audience_ids         : (data.server_api['audience_ids[]']    ? _.ensureArray(data.server_api['audience_ids[]'])     : ''),
                course_types         : (data.server_api['course_types[]']    ? _.ensureArray(data.server_api['course_types[]'])     : ''),
                min_age_for_kids     : (data.server_api.min_age_for_kids     ? data.server_api.min_age_for_kids                     : ''),
                max_age_for_kids     : (data.server_api.max_age_for_kids     ? data.server_api.max_age_for_kids                     : ''),
                price_type           : (data.server_api.price_type           ? data.server_api.price_type                           : ''),
                max_price            : (data.server_api.max_price            ? data.server_api.max_price                            : ''),
                min_price            : (data.server_api.min_price            ? data.server_api.min_price                            : ''),
                structure_types      : (data.server_api['structure_types[]'] ? _.ensureArray(data.server_api['structure_types[]'])  : ''),
                funding_type_ids     : (data.server_api['funding_type_ids[]']? _.ensureArray(data.server_api['funding_type_ids[]']) : ''),
                discount_types       : (data.server_api['discount_types[]']  ? _.ensureArray(data.server_api['discount_types[]'])   : ''),
                week_days            : (data.server_api['week_days[]']       ? _.ensureArray(data.server_api['week_days[]'])        : ''),
                start_date           : (data.server_api.start_date           ? data.server_api.start_date                           : ''),
                end_date             : (data.server_api.end_date             ? data.server_api.end_date                             : ''),
                start_hour           : (data.server_api.start_hour           ? data.server_api.start_hour                           : ''),
                end_hour             : (data.server_api.end_hour             ? data.server_api.end_hour                             : ''),
                is_open_for_trial    : (data.server_api.is_open_for_trial    ? data.server_api.is_open_for_trial                    : '')
            });

            this.trigger('structures:updated:maps');
        },

        structuresUpdated: function structuresUpdated (structure_ids) {
            this.logImpressions(structure_ids);
            this.renderSlideshows();
            setTimeout(this.resize_thumbnails);
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
                GLOBAL.initialize_fancy(self.$('.rslides-wrapper [data-behavior="fancy"]'));
            });
        },

        itemViewOptions: function itemViewOptions () {
            var subject_name = $('[data-value="' + decodeURIComponent(this.collection.server_api.subject_id) + '"]').first().text().trim();
            var search_term = this.collection.server_api.name || "";

            return {
                search_term: decodeURIComponent(search_term),
                subject_name: subject_name
            }
        }

    });
});
