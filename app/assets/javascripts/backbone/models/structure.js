
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
                relatedModel: Backbone.RelationalModel.extend({ }),
                includeInJSON: false,
                reverseRelation: {
                    key: 'structure'
                },
                collectionType: Backbone.Collection.extend({
                    url: function (models) {
                        console.log("URL");
                        if (models === undefined) { return ''; }

                        var model_ids = _.pluck(models, 'id').join(',');

                        return '/etablissements/' + models[0].get('structure').get('id') + '/recommandations/' + model_ids + '.json';
                    }
                })
            },

            {
                type: Backbone.HasMany,
                key: 'courses',
                relatedModel: Backbone.RelationalModel.extend({ }),
                includeInJSON: false,
                reverseRelation: {
                    key: 'structure'
                },
                collectionType: Backbone.Collection.extend({
                    url: function (models) {
                        console.log("URL");
                        if (models === undefined) { return ''; }

                        return '/etablissements/' + models[0].get('structure').get('id') + '/cours.json';
                    }
                })
            }
        ]
    });
});
