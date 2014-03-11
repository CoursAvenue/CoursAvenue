/* just a basic backbone model */
FilteredSearch.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.CoursesCollection = Backbone.Collection.extend({
        resource: "/" + App.resource + "/",

        url: function (models) {
            var params;

            if (models === undefined) { return ''; }

            params = {
                format: 'json',
                id: models[0].get('structure').get('id')
            };

            return Routes.structure_courses_path(params, this.structure.get("query_params"));
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

                        // TODO this used to be
                        //   return App.resource + models[0].get('structure').get('id') + '/recommandations.json';
                        // but it started barfing. It could bite us later
                        return Routes.structure_comments_path({format: 'json', id: models[0].get('structure').get('id')})
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
                        return Routes.structure_medias_path({format: 'json', id: models[0].get('structure').get('id')})
                    }
                })
            }
        ]
    });
});


