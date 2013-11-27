
FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.StructuresCollection = Models.PaginatedCollection.extend({
        model: Models.Structure,

    });
});

