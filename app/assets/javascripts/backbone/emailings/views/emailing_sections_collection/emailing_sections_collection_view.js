/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

Emailing.module('Views.EmailingSectionsCollection', function(Module, App, Backbone, Marionette, $, _) {
    Module.EmailingSectionsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'emailing_sections_collection_view',
        itemView: Module.EmailingSection.EmailingSectionView,
    });
});

