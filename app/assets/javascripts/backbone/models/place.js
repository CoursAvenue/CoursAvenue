
/* link model joins Structures and Locations */
FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Place = Backbone.RelationalModel.extend({
        initialize: function() {
            console.log("Place->initialize");
        }
    });
});
