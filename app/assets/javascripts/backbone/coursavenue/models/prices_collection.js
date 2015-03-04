
/* link model joins Structures and Locations */
CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.PricesCollection = Backbone.Collection.extend({
        model: Models.Price
    });
});
