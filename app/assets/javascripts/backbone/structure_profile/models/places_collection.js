/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.Place = Backbone.Model.extend({
        /* we need this in order to qualify as a Location */
        getLatLng: function() {
            var lat = this.get('latitude');
            var lng = this.get('longitude');

            return new google.maps.LatLng(lat, lng);
        }
    });

    Module.PlacesCollection = Backbone.Collection.extend({
        model: Module.Place,
        url: function() {
            var structure_id  = this.structure.get('id'),
                query_params  = this.structure.get("query_params"),
                route_details = {
                    format: 'json',
                    id: structure_id
                };
            _.extend(query_params, { course_types: ['lesson', 'private']})
            return Routes.structure_places_path(route_details, query_params);
        }
    });
});
