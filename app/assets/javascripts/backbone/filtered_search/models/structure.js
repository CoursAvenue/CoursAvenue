
/* just a basic backbone model */
FilteredSearch.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.CoursesCollection = Backbone.Collection.extend({
        initialize: function () {

        },

        url: function (models) {
            if (models === undefined) { return ''; }

            /* TODO not super happy about this */
            var query = this.structure.collection.getQuery();

            return '/etablissements/' + models[0].get('structure').get('id') + '/cours.json' + query;
        }
    });

    Module.Structure = Backbone.RelationalModel.extend({
        defaults: {
            data_type: 'structure-element'
        },

        relations: [
            {
                type: Backbone.HasMany,
                key: 'places',
                relatedModel: Module.Place,
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
                collectionType: Module.CoursesCollection
            },

            {
                type: Backbone.HasMany,
                key: 'medias',
                relatedModel: Backbone.RelationalModel.extend({ }),
                includeInJSON: false,
                reverseRelation: {
                    key: 'structure'
                },
                collectionType: Backbone.Collection.extend({
                    url: function (models) {
                        if (models === undefined) { return ''; }

                        return '/etablissements/' + models[0].get('structure').get('id') + '/medias.json';
                    }
                })
            }
        ]
    });
});


