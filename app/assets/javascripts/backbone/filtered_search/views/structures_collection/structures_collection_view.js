/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

FilteredSearch.module('Views.StructuresCollection', function(Module, App, Backbone, Marionette, $, _) {
    Module.StructuresCollectionView = CoursAvenue.Views.PaginatedCollectionView.extend({
        template: Module.templateDirname() + 'structures_collection_view',
        itemView: Module.Structure.StructureView,
        itemViewContainer: 'ul.' + FilteredSearch.slug + '__list',
        className: 'relative',

        /* forward events with only the necessary data */
        onItemviewHighlighted: function (view, data) {
            this.trigger('structures:itemview:highlighted', data);
        },

        onItemviewUnhighlighted: function (view, data) {
            this.trigger('structures:itemview:unhighlighted', data);
        },

        onItemviewCourseFocus: function (view, data) {
            this.trigger('structures:itemview:peacock', data);
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        /* remember that itemViews are constructed and destroyed more often
        * than the corresponding models */
        itemViewOptions: function(model, index) {
            // we could pass some information from the collectionView
            var search_term;

            if (this.collection.server_api.name) {
                search_term = decodeURIComponent(this.collection.server_api.name);
            }

            return {
                search_term: search_term
            };
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
                address_name: (data.server_api.address_name ? decodeURIComponent(data.server_api.address_name) : ""),
                name:         (data.server_api.name ? decodeURIComponent(data.server_api.name) : ""),
                subject_id:   (data.server_api.subject_id ? decodeURIComponent(data.server_api.subject_id) : ""),
                level_value:  (data.server_api.level_value ? decodeURIComponent(data.server_api.level_value) : ""),
                course_type:  (data.server_api.course_type ? decodeURIComponent(data.server_api.course_type) : "")
            });

            this.trigger('structures:updated:maps');
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
        }

    });
});

