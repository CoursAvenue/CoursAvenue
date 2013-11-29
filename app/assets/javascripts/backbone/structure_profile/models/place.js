
/* just a basic backbone model */
StructureProfile.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Place = Backbone.Model.extend({
        /* we need this in order to qualify as a Location */
        getLatLng: function() {
            var lat = this.get('location').latitude;
            var lng = this.get('location').longitude;

            return new google.maps.LatLng(lat, lng);
        }
    });
});
