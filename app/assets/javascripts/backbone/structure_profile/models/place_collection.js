
Daedalus.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.PlacesCollection = Backbone.Collection.extend({
        model: Models.Place
    });
});

