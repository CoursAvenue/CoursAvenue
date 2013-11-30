
/* just a basic backbone model */
StructureProfile.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Place = Backbone.Model.extend({
        /* we need this in order to qualify as a Location */
        getLatLng: function() {
            var location = this.get('location');
            return new google.maps.LatLng(location.latitude, location.longitude);
        }
    });
});
