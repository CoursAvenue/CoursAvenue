
/* link model joins Structures and Locations */
CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.PricesCollection = Backbone.Collection.extend({
        model: Models.Price,
        comparator: function comparator (a, b) {
            return (a.get('amount') < b.get('amount'));
        }
    });
});
