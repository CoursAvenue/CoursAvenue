DiscoveryPassSearch.module('Views.StructuresCollection.Filters.Subjects', function(Module, App, Backbone, Marionette, $, _) {

    Module.SubjectsCollectionView = FilteredSearch.Views.StructuresCollection.Filters.Subjects.SubjectsCollectionView.extend({
        template: Module.templateDirname() + 'subjects_collection_view'
    });
});
