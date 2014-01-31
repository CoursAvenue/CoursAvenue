/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

FilteredSearch.module('Views.StructuresCollection', function(Module, App, Backbone, Marionette, $, _) {
    var EmptyStrcutureList = Marionette.ItemView.extend({
        tagName: 'div',
        template: Module.templateDirname() + 'empty_structures_collection_view',

        initialize: function(options) {
            this.search_term  = options.search_term;
            this.subject_name = options.subject_name;
        },

        serializeData: function() {
            return {
                search_term: this.search_term,
                subject_name: this.subject_name
            }
        }

    });

    Module.StructuresCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        template: Module.templateDirname() + 'structures_collection_view',
        itemView: Module.Structure.StructureView,
        itemViewContainer: 'ul.' + FilteredSearch.slug + '__list',
        className: 'relative',

        emptyView: EmptyStrcutureList,

        /* forward events with only the necessary data */
        onItemviewHighlighted: function (view, data) {
            this.trigger('structures:itemview:highlighted', data);
        },

        onItemviewUnhighlighted: function (view, data) {
            this.trigger('structures:itemview:unhighlighted', data);
        },

        /* WHOA so this event is actually getting the course:focus event
        *  via the broadcast method, not by having the itemview actually
        *  trigger anything. Weird. */
        onItemviewCourseFocus: function (view, data) {
            this.trigger('structures:itemview:peacock', data);
        },


        findItemView: function (data) {
            /* find the first place that has any locations that match the given lat/lng */
            var position = data.model.getLatLng();

            var relevant_structure = this.collection.find(function (model) {

                return _.find(model.getRelation('places').related.models, function (place) {
                    var location = place.get('location');
                    var latlng = new google.maps.LatLng(location.latitude, location.longitude);

                    return (position.equals(latlng)); // ha! google to the rescue
                });
            });

            var itemview = this.children.findByModel(relevant_structure);

            /* announce the view we found */
            this.trigger('structures:itemview:found', itemview);
            this.scrollToView(itemview);

        },

        /* override inherited method */
        announcePaginatorUpdated: function () {
            var data         = this.collection;
            var first_result = (data.currentPage - 1) * data.perPage + 1;

            this.trigger('structures:updated');

            /* announce the pagination statistics for the current page */
            this.trigger('structures:updated:pagination', {
                current_page:        data.currentPage,
                last_page:           data.totalPages,
                buttons:             this.buildPaginationButtons(data),
                previous_page_query: this.collection.previousQuery(),
                next_page_query:     this.collection.nextQuery(),
                relevancy_query:     this.collection.relevancyQuery(),
                popularity_query:    this.collection.popularityQuery(),
                sort:                this.collection.server_api.sort
            });

            /* announce the summary of the result set */
            this.trigger('structures:updated:summary', {
                first: first_result,
                last: Math.min(first_result + data.perPage - 1, data.grandTotal),
                total: data.grandTotal,
            });

            /* announce the filters used in the current result set */
            this.trigger('structures:updated:filter', {
                address_name:        (data.server_api.address_name         ? data.server_api.address_name          : ''),
                name:                (data.server_api.name                 ? data.server_api.name                  : ''),
                subject_id:          (data.server_api.subject_id           ? data.server_api.subject_id            : ''),
                level_ids:           (data.server_api['level_ids[]']       ? data.server_api['level_ids[]']        : ''),
                audience_ids:        (data.server_api['audience_ids[]']    ? data.server_api['audience_ids[]']     : ''),
                course_types:        (data.server_api['course_types[]']    ? data.server_api['course_types[]']     : ''),
                min_age_for_kids:    (data.server_api.min_age_for_kids     ? data.server_api.min_age_for_kids      : ''),
                max_age_for_kids:    (data.server_api.max_age_for_kids     ? data.server_api.max_age_for_kids      : ''),
                price_type:          (data.server_api.price_type           ? data.server_api.price_type            : ''),
                max_price:           (data.server_api.max_price            ? data.server_api.max_price             : ''),
                min_price:           (data.server_api.min_price            ? data.server_api.min_price             : ''),
                structure_types:     (data.server_api['structure_types[]'] ? data.server_api['structure_types[]']  : ''),
                funding_type_ids:    (data.server_api['funding_type_ids[]']? data.server_api['funding_type_ids[]'] : ''),
                discount_types:      (data.server_api['discount_types[]']  ? data.server_api['discount_types[]']   : ''),
                week_days:           (data.server_api['week_days[]']       ? data.server_api['week_days[]']        : ''),
                start_date:          (data.server_api.start_date           ? data.server_api.start_date            : ''),
                end_date:            (data.server_api.end_date             ? data.server_api.end_date              : ''),
                start_hour:          (data.server_api.start_hour           ? data.server_api.start_hour            : ''),
                end_hour:            (data.server_api.end_hour             ? data.server_api.end_hour              : ''),
                trial_course_amount: (data.server_api.trial_course_amount  ? data.server_api.trial_course_amount   : '')
            });

            this.trigger('structures:updated:maps');

            this.trigger('structures:updated:infinite_scroll', {
                structures_count: this.collection.length,
                per_page: this.collection.paginator_ui.perPage
            });
        },

        renderSlideshows: function() {
            var self = this;
            setTimeout(function(){
                // Start slideshow
                // Removing images and adding the image url to background image in order to have the image being covered
                self.$('.rslides img').each(function(){
                    var $this = $(this);
                    $this.closest('.media__item').hide();
                    $this.closest('li').css('background-image', 'url(' + $this.attr('src') + ')')
                });
                self.$(".rslides").responsiveSlides({
                    auto: false,
                    nav: true,
                    prevText: '<i class="fa fa-chevron-left"></i>',
                    nextText: '<i class="fa fa-chevron-right"></i>'
                });
                GLOBAL.initialize_fancy(self.$('.rslides-wrapper [data-behavior="fancy"]'));
                // Set the height of relative divs that needs to fits the table cells.
                self.$('.structure-item').each(function() {
                    var $this = $(this);
                    var media_height = $this.height();
                    $this.find('.full-height').css('height', media_height);
                    $this.find('.rslides li').css('height', media_height);
                    $this.find('.rslides').removeClass('hidden');
                });
            });
        },

        itemViewOptions: function() {
            var subject_name = $('[data-value="' + decodeURIComponent(this.collection.server_api.subject_id) + '"]').text().trim();
            return {
                search_term: decodeURIComponent(this.collection.server_api.name),
                subject_name: subject_name
            }
        }

    });
});
