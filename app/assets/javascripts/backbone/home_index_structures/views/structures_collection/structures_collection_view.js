/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

/* StructuresCollectionView */
/* @brief: StructuresCollectionView is a collection view that presents
*   structures in a manner identical to the structures_collection in the
*   filteredsearch module. However, it inherits directly from Compositeview
*   and had no pagination or accordion controller behaviour. */
HomeIndexStructures.module('Views.StructuresCollection', function(Module, App, Backbone, Marionette, $, _) {
    Module.StructuresCollectionView = Backbone.Marionette.CompositeView.extend({

        /* we are using the structures_collection_view template, and the structure_view
        *  as itemview, but we are using out own structure_view template */
        template: FilteredSearch.Views.StructuresCollection.templateDirname() + 'structures_collection_view',
        itemView: FilteredSearch.Views.StructuresCollection.Structure.StructureView.extend({
            template: Module.Structure.templateDirname() + 'structure_view'
        }),

        itemViewContainer: 'ul',
        className: 'structures-collection',

        initialize: function() {
            this.collection.on('reset', function() {
                setTimeout(function(){
                    $('body').stickem();
                }, 500);
            });
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        /* remember that itemViews are constructed and destroyed more often
        * than the corresponding models */
        itemViewOptions: function(model, index) {
            return { };
        },

        /* override inherited method */
        announceStructuresUpdated: function () {
            var data = this.collection;

            this.trigger('structures:updated');
        },

        /* TODO: these should be pulled out into a concern */
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

        /* TODO: this should be added to collectionview at the top level */
        scrollToView: function(view) {
            var element = view.$el;

            this.$el.parents('section').scrollTo(element[0], {duration: 400});
        },

        /* TODO: these should be pulled out into a concern */
        onItemviewHighlighted: function (view, data) {
            this.trigger('structures:itemview:highlighted', data);
        },

        onItemviewUnhighlighted: function (view, data) {
            this.trigger('structures:itemview:unhighlighted', data);
        },
    });
});

