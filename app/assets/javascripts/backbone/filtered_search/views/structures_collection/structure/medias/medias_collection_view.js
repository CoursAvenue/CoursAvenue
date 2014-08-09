FilteredSearch.module('Views.StructuresCollection.Structure.Medias', function(Module, App, Backbone, Marionette, $, _) {

    Module.MediasCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'medias_collection_view',
        // The "value" has an 's' at the end, that's what the slice is for
        childView: Module.MediaView,
        childViewContainer: '[data-type=container]',

        onRender: function() {
            GLOBAL.initialize_fancy(this.$('a[data-behavior="fancy"]'));
        }
    });

});
