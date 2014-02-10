/* just a basic backbone model */
FilteredSearch.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.CoursesCollection = Backbone.Collection.extend({
        resource: "/" + App.resource + "/",

        url: function (models) {
            var query = "";

            if (models === undefined) { return ''; }

            /* TODO not super happy about this */
            // TODO this has become a problem, since we are now using structure
            // in a context where it has no "collection"
            if (this.structure.collection && _.isFunction(this.structure.collection.getQuery)) {
                query = this.structure.collection.getQuery();
            } else {

                // TODO this is clearly just a temporary solution
                var lat = coursavenue.bootstrap.places[0].location.latitude,
                    lng = coursavenue.bootstrap.places[0].location.longitude;

                query = "?lat=" + lat + "&lng=" + lng;
            }

            return this.resource + models[0].get('structure').get('id') + '/cours.json' + query;
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
                icon: 'comments',
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
                        return models[0].get('structure').get('id') + '/recommandations.json?unlimited_comments=true';
                    }
                })
            },

            {
                type: Backbone.HasMany,
                key: 'courses',
                icon: 'calendar',
                relatedModel: Backbone.RelationalModel.extend({ }),
                includeInJSON: false,
                reverseRelation: {
                    key: 'structure'
                },
                collectionType: Module.CoursesCollection
            },

            {
                type: Backbone.HasMany,
                key: 'teachers',
                icon: 'group',
                relatedModel: Backbone.RelationalModel.extend({ }),
                includeInJSON: false,
                reverseRelation: {
                    key: 'structure'
                },
                collectionType: Module.TeachersCollection
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

                        return models[0].get('structure').get('id') + '/medias.json';
                    }
                })
            }
        ]
    });
});


