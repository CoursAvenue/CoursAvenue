Emailing.module('Views.EmailingSectionsCollection', function(Module, App, Backbone, Marionette, $, _) {
    Module.EmailingSectionsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'emailing_section_bridges_collection_view',
        itemView: Module.EmailingSectionBridgeView
    });
});

