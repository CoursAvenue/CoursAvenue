
DiscoveryPassSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.DateFilterView = FilteredSearch.Views.StructuresCollection.Filters.DateFilterView.extend({
        template: Module.templateDirname() + 'date_filter_view',
    });
});

