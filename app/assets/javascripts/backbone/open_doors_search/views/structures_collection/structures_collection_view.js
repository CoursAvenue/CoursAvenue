
OpenDoorsSearch.module('Views.StructuresCollection', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructuresCollectionView = FilteredSearch.Views.StructuresCollection.StructuresCollectionView.extend({
        childView: Module.Structure.StructureView
    });
});
