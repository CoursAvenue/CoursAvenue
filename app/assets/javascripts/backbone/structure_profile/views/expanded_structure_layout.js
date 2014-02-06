StructureProfile.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    /* TODO should rename this to RelationalTabLayout, I think */
    Module.ExpandedStructureLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'expanded_structure_layout',
        className: 'expanded-structure-layout',
        master_region_name: 'expanded_structure',

        initialize: function () {
            this.tabs = ["comments", "courses"];
            this.default_tab = this.tabs[0];

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
            var relations     = this.serializeRelations(this.tabs);

            var relation_name = this.default_tab;
            var active_tab    = _.first(_.where(relations, { slug: relation_name }));

            // give the default tab some comments
            active_tab.isEmpty        = this.model.get(relation_name).length > 0 ? false : true;
            active_tab[relation_name] = this.model.get(relation_name);

            return {
                tab: active_tab,
                relations: relations
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

