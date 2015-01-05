/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

Emailing.module('Views.Sections', function(Module, App, Backbone, Marionette, $, _) {
    Module.SectionsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'sections_collection_view',
        childView: Module.SectionView,
        childViewContainer: '[data-type=container]',

        childViewOptions: function childViewOptions (model, index) {
            return {
                model:      model,
                collection: model.get('bridges')
            };
        }
    });
});

