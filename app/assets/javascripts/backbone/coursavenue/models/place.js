
/* link model joins Structures and Locations */
CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Place = Backbone.Model.extend({

        /* we need this in order to qualify as a Location */
        getLatLng: function() {
            var lat = this.get('latitude');
            var lng = this.get('longitude');

            return new google.maps.LatLng(lat, lng);
        }
    });
});
