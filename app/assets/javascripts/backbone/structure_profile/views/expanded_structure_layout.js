StructureProfile.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    /* TODO should rename this to RelationalTabLayout, I think */
    Module.ExpandedStructureLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'expanded_structure_layout',
        className: 'expanded-structure-layout',
        master_region_name: 'expanded_structure',

        initialize: function () {
            this.tabs = ["comments", "courses"];
        },

        regions: {
            master: "#map-places",
        },

        onShow: function() {
            if (App.$loader) {
                App.$loader().fadeOut('slow');
            }
        },

        serializeData: function () {

            return {
                relations: this.serializeRelations(this.tabs)
            };
        },

        serializeRelations: function (tabs) {

            return _.reduce(this.model.relations, function (memo, relation) {
                var slug   = relation.key;
                var icon   = relation.icon;
                var active = "";

                // serialize the given relation if it is on our whitelist
                if (tabs.indexOf(slug) > -1) {
                    active = (memo.length === 0)? "active" : "";

                    memo.push({
                        active: active,
                        name: _.capitalize(slug),
                        slug: slug,
                        icon: icon
                    });
                }

                return memo;
            }, []);
        }


    });
});

