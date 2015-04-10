
/* link model joins Structures and Locations */
CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.PricesCollection = Backbone.Collection.extend({
        model: Models.Price,
        comparator: function comparator (a, b) {
            return (parseFloat(a.get('amount'), 10) > parseFloat(b.get('amount'), 10));
        }
    });
});
