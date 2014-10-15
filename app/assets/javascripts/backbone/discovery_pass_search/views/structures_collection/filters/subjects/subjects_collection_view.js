DiscoveryPassSearch.module('Views.StructuresCollection.Filters.Subjects', function(Module, App, Backbone, Marionette, $, _) {

    Module.SubjectsCollectionView = FilteredSearch.Views.StructuresCollection.Filters.Subjects.SubjectsCollectionView.extend({
        template: Module.templateDirname() + 'subjects_collection_view',

        serializeData: function serializeData () {
            return {
              discovery_pass_danse_test: $.cookie('discovery_pass_danse_test')
            };
        }

    });
});
