/* just a basic backbone model */
CoursAvenue.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.CoursesCollection = Backbone.Collection.extend({
        resource: "/" + App.resource + "/",

        url: function (models) {
            var structure_id  = this.structure.get('id'),
                query_params  = this.structure.get("query_params"),
                route_details = {
                    format: 'json',
                    id: structure_id
                };

            /* backboneRelational expects url(models) to return a URL
            *  different from just calling url() without a models params.
            *  Normally, url would build a URL including something like
            *  "&ids=1,2,3" but in our case the URL doesn't actually
            *  differ. So we are just returning an empty string to trick
            *  backbonerelational. */
            if (!structure_id && models === undefined) { return ''; }

            return Routes.structure_courses_path(route_details, query_params);
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
                },
                collectionType: Backbone.Collection.extend({
                    url: function (models) {

                        /* backboneRelational expects url(models) to return a URL
                        *  different from just calling url() without a models params.
                        *  Normally, url would build a URL including something like
                        *  "&ids=1,2,3" but in our case the URL doesn't actually
                        *  differ. So we are just returning an empty string to trick
                        *  backbonerelational. */
                        var url = Routes.structure_places_path({format: 'json', id: this.structure.get('id')})
                        if (models === undefined) { return url + '?'; }

                        return url;
                    }
                })
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
                        var structure_id = this.structure.get('id'),
                            query_params = { unlimited_comments: true };

                        /* backboneRelational expects url(models) to return a URL
                        *  different from just calling url() without a models params.
                        *  Normally, url would build a URL including something like
                        *  "&ids=1,2,3" but in our case the URL doesn't actually
                        *  differ. So we are just returning an empty string to trick
                        *  backbonerelational. */
                        if (!structure_id && models === undefined) { return ''; }

                        return Routes.structure_comments_path({ format: 'json', id: structure_id || models[0].get('structure').get('id') }, query_params);
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
                collectionType: Backbone.Collection.extend({
                    url: function (models) {
                        var structure_id = this.structure.get('id');

                        if (!structure_id && models === undefined) { return ''; }

                        return Routes.structure_teachers_path({ format: 'json', id: structure_id || models[0].get('structure').get('id') })
                    }
                })
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

                        /* backboneRelational expects url(models) to return a URL
                        *  different from just calling url() without a models params.
                        *  Normally, url would build a URL including something like
                        *  "&ids=1,2,3" but in our case the URL doesn't actually
                        *  differ. So we are just returning an empty string to trick
                        *  backbonerelational. */
                        if (models === undefined) { return ''; }

                        return Routes.structure_medias_path({format: 'json', id: models[0].get('structure').get('id')})
                    }
                })
            }
        ]
    });
});


