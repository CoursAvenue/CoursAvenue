
/* just a basic backbone model */
Daedalus.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    // we want to be able to override some relations
    var relations = FilteredSearch.Models.Structure.prototype.relations;


    Module.Structure = FilteredSearch.Models.Structure.extend({
        relations: relations
    });
});

