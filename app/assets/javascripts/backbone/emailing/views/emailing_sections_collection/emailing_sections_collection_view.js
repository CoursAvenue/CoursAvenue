/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

Emailing.module('Views.EmailingSectionsCollection', function(Module, App, Backbone, Marionette, $, _) {
    Module.EmailingSectionsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'emailing_sections_collection_view',
        itemView: Module.EmailingSection.EmailingSectionView,
        itemViewContainer: 'tbody',
        className: 'emailing-sections-collection',

        /* TODO choose a model to represent the composite portion, if you want */
        model: Emailing.Models.SomeModel,

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        /* remember that itemViews are constructed and destroyed more often
        * than the corresponding models */
        itemViewOptions: function(model, index) {
            return { };
        },

        /* override inherited method */
        announceEmailingSectionsUpdated: function () {
            var data = this.collection;

            this.trigger('emailing:sections:updated');

        },
    });
});

