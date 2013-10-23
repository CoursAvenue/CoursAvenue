
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
            },

            {
                type: Backbone.HasMany,
                key: 'comments',
                keySource: 'id',
                relatedModel: Backbone.RelationalModel.extend({ }),
                includeInJSON: false,
                reverseRelation: {
                    key: 'structure'
                },
                collectionType: Backbone.Collection.extend({
                    url: function (model) {
                        console.log("URL");

                        return '/etablissements/' + model[0].id + 'recommandations.json';
                    }
                })
            }
        ]
    });
});
