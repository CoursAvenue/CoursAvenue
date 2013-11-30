StructureProfile = (function (){
    var self = new Backbone.Marionette.Application({
        slug: 'structure-profile',

        /* for use in query strings */
        root:   function() { return self.slug + '-root'; },
        loader: function() { return self.slug + '-loader'; },
        /* methods for returning the relevant jQuery collections */
        $root: function() {
            return $('[data-type=' + self.root() + ']');
        },

        /* Return the element in which the application will be appended */
        $loader: function() {
            return $('[data-type=' + self.loader() + ']');
        },

        /* A StructureProfile should only start if it detects
         * an element whose data-type is the same as its
         * root property.
         * @throw the root was found to be non-unique on the page */
        detectRoot: function() {
            var result = self.$root().length;

            if (result > 1) {
                throw {
                    message: 'StructureProfile->detectRoot: ' + self.root() + ' element should be unique'
                }
            }

            return result > 0;
        },
    });

    return self;
}());

StructureProfile.addRegions({
    mainRegion: '#' + StructureProfile.slug
});

StructureProfile.addInitializer(function(options) {
    var bootstrap, places, places_view, layout, maps_view, $loader;
    bootstrap = window.coursavenue.bootstrap;

    // Create an instance of your class and populate with the models of your entire collection
    places = new StructureProfile.Models.PlacesCollection(bootstrap.models);
    /* set up the layouts */
    layout = new StructureProfile.Views.StructureProfileLayout();

    // var bounds = places.getLatLngBounds();
    google_maps_view = new CoursAvenue.Views.Map.GoogleMapsView({
        collection: places,
        infoBoxOptions: {
            template: StructureProfile.module('Views.Map').templateDirname() + 'place_info_box_view'
        }

    });
    StructureProfile.mainRegion.show(layout);

    /* we can add a widget along with a callback to be used
    * for setup */
    layout.showWidget(google_maps_view);

});

$(document).ready(function() {
    /* we only want the StructureProfile on the search page */
    if (StructureProfile.detectRoot()) {
        StructureProfile.start({});
    }

});
