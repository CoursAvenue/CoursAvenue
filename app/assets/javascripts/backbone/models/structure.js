/* link model joins Structures and Locations */
FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Place = Backbone.RelationalModel.extend({
        initialize: function() {
            console.log("Place->initialize");
        }
    });
});

/* just a basic backbone model */
FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Structure = Backbone.RelationalModel.extend({
        defaults: {
            data_type: 'structure-element'
        },
        relations: [
            {
              type: Backbone.HasMany,
              key: 'places',
              relatedModel: Models.Place,
              includeInJSON: false, // when serializing Structure, we don't need this
              // collectionType: Models.PlaceCollection,
              reverseRelation: {
                  key: 'structure' // place has a structure
              }
            }
        ],
        initialize: function() {
            console.log("Structure->initialize");
        }
    });
});

FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Location = Backbone.RelationalModel.extend({
        relations: [
            {
              type: Backbone.HasMany,
              key: 'places',
              relatedModel: Models.Place,
              includeInJSON: false, // when serializing Structure, we don't need this
              // collectionType: Models.LocationCollection,
              reverseRelation: {
                  key: 'location' // place has a location
              }
            }
        ],
        initialize: function() {
            console.log("Location->initialize");
        }
    });
});
