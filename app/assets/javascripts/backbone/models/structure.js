
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
              reverseRelation: {
                  key: 'structure' // place has a structure
              }
            }
        ]
    });
});
