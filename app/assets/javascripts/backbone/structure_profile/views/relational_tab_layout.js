StructureProfile.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    /* TODO should rename this to RelationalTabLayout, I think */
    Module.RelationalTabLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'relational_tab_layout',
        className: 'replational-tab-layout',
        master_region_name: 'relational-tabs',

        initialize: function () {
            this.tabs = ["comments", "courses"];
            this.default_tab = this.tabs[0];

        },

        ui: {
            '$tabs' : '[data-toggle=tab]'
        },

        events: {
            'click @ui.$tabs': 'tabControl'
        },

        /* similar to accordioncontrol... very similar.
         *  differences: we build the tab toggles based on the known relations
         *      on the model, so we don't have to "add an s" in the code bellow,
         *      because the data-model is already plural. This is something I should
         *      consider adding to accordioncontrol.
         *      TODO: it makes more sense for the tabs to have data-relation rather than
         *       data-model, so I'm going to change this here and then fix it in the other
         *       place later. */
        tabControl: function (e) {
            e.preventDefault();

            var relation_name   = $(e.currentTarget).data('relation'), // the relation name
                model_name      = _.singularize(relation_name ), // note we are not adding an s here
                collection_name = relation_name + '_collection',
                collection_slug = collection_name.replace('_', '-'),
                attributes      = ($(e.currentTarget).data('attributes') ? $(e.currentTarget).data('attributes').split(' ') : {}),
                self            = this;

            /* if no region exists on the structure view, then we need to
            *  fetch the relation, and create a region for it */
            if (this.regions[collection_name] === undefined) {
                this.showLoader(collection_name);
                /* wait for asynchronous fetch of models before adding region */
                this.model.fetchRelated(relation_name, { data: { search_term: this.search_term }}, true)[0].then(function () {
                    self.createRegionFor(relation_name, attributes);
                    // self.accordionToggle(collection_name, model_name); // we may not need this
                    // we will need to retrigger the event at this point, though... hmm
                    // since the tabbing is being managed by bootstrap
                    self.hideLoader();
                });
            } else {
                // this.accordionToggle(collection_name, model_name);
            }

            return false;
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

