StructureProfile.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    /* TODO should rename this to RelationalTabLayout, I think */
    Module.RelationalTabLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'relational_tab_layout',
        className: 'replational-tab-layout',
        master_region_name: 'relational-tabs',

        initialize: function () {
            this.getModuleForRelation = _.bind(this.getModuleForRelation, Module);
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

            var relation_name   = $(e.currentTarget).data('relation'), // the relation name
                model_name      = _.singularize(relation_name ), // note we are not adding an s here
                collection_name = relation_name + '_collection',
                collection_slug = collection_name.replace('_', '-'),
                // TODO we don't have a data-attributes attribute yet
                attributes      = ($(e.currentTarget).data('attributes') ? $(e.currentTarget).data('attributes').split(' ') : {}),
                self            = this;

            /* if no region exists on the structure view, then we need to
            *  fetch the relation, and create a region for it */
            if (this.regions[collection_name] === undefined) {
                // this.showLoader(collection_name); // TODO we don't have a loader yet
                /* wait for asynchronous fetch of models before adding region */
                this.model.fetchRelated(relation_name, { data: { search_term: this.search_term }}, true)[0].then(function () {
                    self.createRegionFor(relation_name, attributes);
                    // self.accordionToggle(collection_name, model_name); // we may not need this
                    // self.hideLoader();
                });
            } else {
                // this.accordionToggle(collection_name, model_name);
            }
        },

        /* any implementation of RelationalAccordionView must do this */
        /*    this.getModuleForRelation = _.bind(this.getModuleForRelation, Module); */
        getModuleForRelation: function (relation) {
            var keys = this.modulePath.split('.');
            keys.push(_.capitalize(relation));

            var Relation = _.inject(keys, function (memo, key) {
                if (memo[key]) {
                    memo = memo[key];
                }

                return memo;

            }, this.app);

            return Relation;
        },

        /* given a string, find the relation on the model with that name
        *  and create a region, and a composite view. Data for the composite
        *  view is grabbed from the structure, based on strings passed in
        *  an array. The collection is models on a relation on structure. */
        createRegionFor: function (relation_name, attribute_strings) {
            var model_name   = relation_name.slice(0, -1),
                Relations    = this.getModuleForRelation(relation_name), // the module in which the relation views will be
                self         = this, collection, ViewClass, view;

            /* collect some attributes to pass in to the compositeview */
            var data = _.inject(attribute_strings, function (memo, attr) {
                memo[attr] = self.model.get(attr);

                return memo;
            }, {});

            // we don't want to add the hook twice
            var selector = "[data-type=" + relation_name + "-collection]";
            if (this.$(selector).length < 1) {
                this.$('#tab-' + relation_name).append('<div data-type="' + relation_name + '-collection">');
            }

            collection = new Backbone.Collection(this.model.get(relation_name).models);

            /* an anonymous compositeView is all we need */
            // If a collection view exists, then use it, else create a generic one.
            if (Relations[_.capitalize(relation_name) + 'CollectionView']) {
                ViewClass = Relations[_.capitalize(relation_name) + 'CollectionView'];
            } else {
                ViewClass = Backbone.Marionette.CompositeView.extend({
                    template: Relations.templateDirname() + relation_name + '_collection_view',

                    itemView: Relations[_.capitalize(model_name) + 'View'],
                    itemViewContainer: '[data-type=container]'
                });
            }

            view = new ViewClass({
                collection: collection,
                model: new Backbone.Model(data),
                attributes: {
                    'data-behavior': 'accordion-data',
                    'style':         'display:none'
                }
            });

            this.showWidget(view);
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
                        isActive: active === "active",
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

