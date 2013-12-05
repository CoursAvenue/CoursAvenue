
/* TopStructuresCollection */
/* @brief: TopStructuresCollection is a simple collection whose data-source is
*   etablissement/best.json
*   The model is structure, from FilteredSearch, but there is no support of
*   the pagination behaviour.
*   */
HomeIndexStructures.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.TopStructuresCollection = Backbone.Collection.extend({
        model: FilteredSearch.Models.Structure,
        server_api: {
            lat: 48.8567,
            lng: 2.3508
        },

        url: function () {
            return 'etablissement/best.json';
        },

        /* we will receive an object with meta and structures */
        parse: function (data) {
            return data.structures;
        },

        /* return an object with lat, lng, and a bounding box parsed from server_api */
        /* the outside world must never know that we store the bounds as CSV... */
        getLatLngBounds: function () {
            var sw_latlng, ne_latlng;

            if (this.server_api.bbox_sw && this.server_api.bbox_ne) {
                sw_latlng = this.server_api.bbox_sw.split(',');
                ne_latlng = this.server_api.bbox_ne.split(',');

                sw_latlng = {
                    lat: parseFloat(sw_latlng[0]),
                    lng: parseFloat(sw_latlng[1])
                };

                ne_latlng = {
                    lat: parseFloat(ne_latlng[0]),
                    lng: parseFloat(ne_latlng[1])
                };
            }

            /* yup, everything is nice objects over here! */
            return {
                lat: this.server_api.lat,
                lng: this.server_api.lng,
                bbox: {
                    sw: sw_latlng,
                    ne: ne_latlng
                }
            };
        }
    });
});

