StructureProfile.module('Views.Structure', function(Module, App, Backbone, Marionette, $, _) {

    /* TODO should rename this to RelationalTabLayout, I think */
    Module.RelationalTabLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'relational_tab_layout',
        className: 'replational-tab-layout',
        master_region_name: 'relational-tabs',

        initialize: function initialize () {
            this.getModuleForRelation = _.bind(this.getModuleForRelation, Module);
            this.tabs = ["comments", "courses", "teachers"];
            this.default_tab = this.tabs[1];

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
        tabControl: function tabControl (e) {
            var relation_name   = $(e.currentTarget).data('relation'), // the relation name
                model_name      = _.singularize(relation_name ), // note we are not adding an s here
                collection_name = relation_name + '_collection',
                collection_slug = collection_name.replace('_', '-'),
                // TODO we don't have a data-attributes attribute yet
                // we will use this to feed data to the CompositeView
                attributes      = ($(e.currentTarget).data('attributes') ? $(e.currentTarget).data('attributes').split(' ') : {}),
                promise;

            /* if no region exists on the structure view, then we need to
            *  fetch the relation, and create a region for it */
            if (this.regions[collection_name] === undefined) {
                // this.showLoader(collection_name); // TODO we don't have a loader yet
                /* wait for asynchronous fetch of models before adding region */
                promise = this.promiseForFetch(relation_name, attributes);
            } else {
                // this.tagToggle(collection_name, model_name);
            }

            return promise;
        },

        /* a relation will have either 2 attributes (the id and backreference)
         * or many, if it is already loaded. If the model appears to already
         * be loaded, then the promise that is returned will already be resolved. */
        promiseForFetch: function promiseForFetch (relation_name, attributes) {
            var promise, callback = _.bind(function () {

                this.createRegionFor(relation_name, attributes);
            }, this);

            // models that have been fetched will have more than 2 attributes
            var fetched = this.model.get(relation_name).filter(function (model) {
                return _.keys(model.attributes).length > 2;
            }, this);

            if (fetched.length == 0) {
                promise = this.model.fetchRelated(relation_name, { data: { search_term: this.search_term }}, true)[0].then(callback);
            } else {
                // if the model has already been fetched, resolve the promise immediately
                promise = new $.Deferred();
                promise.then(callback);
                promise.resolve();
            }

            return promise;
        },

        /* any implementation of RelationalAccordionView must do this */
        /*    this.getModuleForRelation = _.bind(this.getModuleForRelation, Module); */
        /* TODO problem! If the module for the given relation doesn't exist,
         * such as will be the case when there is no view defined in the
         * project */
        getModuleForRelation: function getModuleForRelation (relation) {
            var keys = this.modulePath.split('.');
            keys.push(_.capitalize(relation));

            var Relation = _.inject(keys, function (memo, key) {
                if (memo[key] === undefined) {
                    App.module(memo.modulePath + "." + key);
                }

                memo = memo[key];

                return memo;

            }, this.app);

            return Relation;
        },

        /* given a string, find the relation on the model with that name
        *  and create a region, and a composite view. Data for the composite
        *  view is grabbed from the structure, based on strings passed in
        *  an array. The collection is models on a relation on structure. */
        createRegionFor: function createRegionFor (relation_name, attribute_strings) {
            var model_name   = relation_name.slice(0, -1),
                Relations    = this.getModuleForRelation(relation_name), // the module in which the relation views will be
                collection, ViewClass, view;

            /* collect some attributes to pass in to the compositeview */
            var data = _.inject(attribute_strings, _.bind(function (memo, attr) {
                memo[attr] = this.model.get(attr);

                return memo;
            }, this), {});

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
                var item_view = Relations[_.capitalize(model_name) + 'View'];
                if (item_view === undefined) {
                    throw new Error("ItemView for " + _.capitalize(model_name) + " is undefined. Did you forget the manifest.js");
                }

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
                }
            });

            this.showWidget(view);
        },

        regions: {
            master: "#map-places",
        },

        /* TODO I am adding the active class myself when the first active
         * tab is shown. This shouldn't need promises: I should really not
         * be depending on Bootstrap to do my tab logic for me. Later I will
         * implement tab logic here. */
        onShow: function() {
            var tab  = this.$(".active > [data-toggle=tab]");

            // wait for the relational tab view to be available
            $.when( this.tabControl({ currentTarget: tab }) ).then(_.bind(function () {
                this.$('#tab-courses').addClass("active");
            }, this));

            if (App.$loader) {
                App.$loader().fadeOut('slow');
            }
        },

        serializeData: function serializeData () {
            var active_relation_name = this.default_tab;
            var relations            = this.serializeRelations(this.tabs, active_relation_name);

            return {
                relations: relations
            };
        },

        serializeRelations: function serializeRelations (tabs, active_relation_name) {

            return _.reduce(this.model.relations, function (memo, relation) {
                var slug   = relation.key;
                var icon   = relation.icon;
                var active = "";

                // serialize the given relation if it is on our whitelist
                if (tabs.indexOf(slug) > -1) {
                    active = (slug === active_relation_name)? "active" : "";

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

