
FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.StructuresCollection = CoursAvenue.Lib.Models.PaginatedCollection.extend({
        model: Models.Structure,

    });
});

