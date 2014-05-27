
/* just a basic marionette view */
StructureProfile.module('Views.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = CoursAvenue.Views.EventLayout.extend({
        className: 'tabs-container',
        template: Module.templateDirname() + 'structure_view',

        ui: {
            '$loader'           : '[data-loader]',
            '$summary_container': '[data-summary-container]',
            '$empty_courses'    : '[data-empty-courses]'
        },

        events: {
            'breadcrumbs:clear'       : 'broadenSearch',
            'filter:popstate'         : 'narrowSearch',
            'courses:collection:reset': 'renderCourseSummary',
            'filter:removed'          : 'removeSummary',
            'click [data-toggle=tab] ': 'showOrCreateTab'
        },

        removeSummary: function () {
            this.$('[data-type="filter-breadcrumbs"]').slideUp();
            this.broadenSearch();
        },

        initialize: function initialize () {
            _.bindAll(this, "showOrCreateTab", "hideLoader");

            this.empty_relation_handlers = {
                "trainings": this.showEmptyCourses,
                "courses": this.showEmptyCourses,
                "places" : this.showEmptyMap,
            };
            $('#structure-header').sticky({
                z: 25,
                onStick: function() {
                    $('#structure-profile-title').append($('[data-type="filter-breadcrumbs"]'));
                },
                onUnStick: function() {
                    $('#structure-profile-description').append($('[data-type="filter-breadcrumbs"]'));
                }
            });

        },

        onAfterShow: function onAfterShow () {
            this.trigger("filter:breadcrumbs:add", this.model.get("query_params"));
        },

        onRender: function onRender () {
            var $currently_active_tab = $(".tabs li.active [data-toggle]");
            this.showOrCreateTab({ currentTarget: $currently_active_tab[0] });
        },

        /* broadenSearch
         * ----------------------
         *
         * without arguments, this function causes the model to fetch its
         * courses and places with no params. If given an argument that has
         * key/value pairs, params matching the values will be removed.
         * So if an object like,
         *
         *   { behavior="tooltip", target="audience_ids", type="clear" }
         *
         * the params "tooltop", "audience_ids", and "clear" will be removed.
         *
         * TODO This is not very precise, though. What are all those extra k/v pairs?
         *  */
        broadenSearch: function broadenSearch (data) {
            var params = this.model.get("query_params");

            if (data === undefined) {
                params = {};
            } else {
                _.each(data, function (value, key) {
                    if (_.has(params, value)) {
                        delete params[value];
                    }
                });
            }

            this.model.set("query_params", params);

            this.updateModelWithRelation("courses");
            this.updateModelWithRelation("trainings");
            this.updateModelWithRelation("places");
        },

        /* narrowSearch
         * ------------
         *
         * This function refetches the course and places relations with
         * the full url query.
         *  */
        narrowSearch: function narrowSearch () {
            // need to parse the search... blech
            var params = CoursAvenue.Models.PaginatedCollection.prototype.makeOptionsFromSearch.call(this, window.location.search);

            this.model.set("query_params", params);

            this.updateModelWithRelation("courses").then(function () {
                this.ui.$summary_container.slideDown();
                this.summary_view.enableRemoveFilterButton();
            }.bind(this));

            this.updateModelWithRelation("trainings");
            this.updateModelWithRelation("places");
        },

        /*
         * Fetch associated relation passing it the query_params
         */
        updateModelWithRelation: function updateModelWithRelation (relation) {
            var fetch = this.model.get(relation).fetch({ data: this.model.get("query_params")});

            if (fetch !== undefined) {
                fetch.then(function (resources) {
                    this.model.get(relation).reset(resources);
                }.bind(this));
            } else {
                // if the fetch is undefined, we don't have any of that resource
                handler = this.empty_relation_handlers[relation];

                if (_.isFunction(handler)) {
                    handler.call(this);
                }
            }

            return fetch || new $.Deferred().reject();
        },

        showEmptyCourses: function showEmptyCourses () {
            this.ui.$empty_courses.show();
        },

        showOrCreateTab: function showOrCreateTab (e) {
            var $target   = $(e.currentTarget),
                resources = $target.data("view"),
                ViewClass, view, model, fetch;

            // if this tab has no associated resource, or if it is already populated, we bail
            if (!resources) { return; }

            ViewClass = this.findOrCreateCollectionViewForResource(resources);

            // Only fetch when there is no data
            view = new ViewClass({
                collection: this.model.get(resources),
                data_url: this.model.get("data_url")
            });

            // Don't fetch resources if it already exists
            // if (this.model.get(resources).length > 0) { return; }

            // always fetch, since we don't know whether we have resources or just ids
            this.showLoader(resources);
            this.updateModelWithRelation(resources)
                .then(function (collection) {
                    if (resources === "courses") {
                        this.summary_view = new StructureProfile.Views.Structure.Courses.CoursesSummaryView(view.serializeData());
                        this.showWidget(this.summary_view, {
                            events: {
                                'courses:collection:reset': 'rerender'
                            }
                        });
                    }

                    this.showWidget(view);
                    $target.data("view", null); // remove the data-view property, indicating that no further fetching should be done

                }.bind(this))
                .always(function() { this.hideLoader(resources) }.bind(this));
        },

        renderCourseSummary: function renderCourseSummary (data) {
            this.summary_view.rerender(data);
        },

        showLoader: function showLoader (resources_name) {
            $('#tab-' + resources_name).append(this.ui.$loader);
            this.$('[data-' + resources_name + '-loader]').show();
        },

        hideLoader: function hideLoader (resources_name) {
            this.$('[data-' + resources_name + '-loader]').hide();
        },

        /*
         * Tries to get an existing collectonView for the given resource
         * If it doesn't exist it creates a default abstract CollectionView
         */
        findOrCreateCollectionViewForResource: function findOrCreateCollectionViewForResource (resources) {
            var resource = _.singularize(resources),
                ViewClass;

            if (Module[_.capitalize(resources)] && Module[_.capitalize(resources)][_.capitalize(resources) + 'CollectionView']) {
                ViewClass = Module[_.capitalize(resources)][_.capitalize(resources) + 'CollectionView'];

            } else {
                ViewClass = Backbone.Marionette.CollectionView.extend({
                    template: Module.templateDirname() + resources + '/' + resources + '_collection_view',
                    itemView: Marionette.ItemView.extend({
                        template: Module.templateDirname() + resources + '/' + resource + '_view'
                    }),
                    // TODO this seems like it shouldn't be necessary...
                    // I thought this would just happen automatically?
                    collectionEvents: {
                        'change': 'render'
                    }
                });
            }

            return ViewClass;
        }
    });
});
