/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

/* TopStructuresCollectionView */
/* @brief: TopStructuresCollectionView is a collection view that presents
*   structures in a manner identical to the structures_collection in the
*   filteredsearch module. However, it inherits directly from Compositeview
*   and had no pagination or accordion controller behaviour. */
HomeIndexStructures.module('Views.TopStructuresCollection', function(Module, App, Backbone, Marionette, $, _) {
    Module.TopStructuresCollectionView = Backbone.Marionette.CompositeView.extend({

        /* we are using the structures_collection_view template, and the structure_view
        *  as itemview, but we are using out own structure_view template */
        template: FilteredSearch.Views.StructuresCollection.templateDirname() + 'structures_collection_view',
        itemView: FilteredSearch.Views.StructuresCollection.Structure.StructureView.extend({
            template: Module.TopStructure.templateDirname() + 'top_structure_view'
        }),

        itemViewContainer: 'ul',
        className: 'top-structures-collection',

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        /* remember that itemViews are constructed and destroyed more often
        * than the corresponding models */
        itemViewOptions: function(model, index) {
            return { };
        },

        /* override inherited method */
        announceTopStructuresUpdated: function () {
            var data = this.collection;

            this.trigger('top:structures:updated');

        },
    });
});

