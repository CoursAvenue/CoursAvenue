
DiscoveryPassSearch.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructuresCollection = FilteredSearch.Models.StructuresCollection.extend({
        url: {
            resource: '/' + App.resource,
            data_type: '.json'
        },
    });
});
