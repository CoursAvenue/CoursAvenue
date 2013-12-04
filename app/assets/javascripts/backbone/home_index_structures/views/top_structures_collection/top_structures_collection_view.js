/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

HomeIndexStructures.module('Views.TopStructuresCollection', function(Module, App, Backbone, Marionette, $, _) {
    Module.TopStructuresCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'top_structures_collection_view',
        itemView: Module.TopStructure.TopStructureView,
        itemViewContainer: 'tbody',
        className: 'top-structures-collection',

        /* TODO choose a model to represent the composite portion, if you want */
        model: HomeIndexStructures.Models.SomeModel,

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

