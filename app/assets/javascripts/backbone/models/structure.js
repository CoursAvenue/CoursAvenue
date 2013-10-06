/* just a basic backbone model */
FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Structure = Backbone.Model.extend({
        defaults: {
            data_type: 'structure-element'
        },
        initialize: function() {
            console.log("Structure->initialize");
        }
    });
});
