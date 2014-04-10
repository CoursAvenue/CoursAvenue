
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
            "filter:removed": 'removeSummary'
        },

        removeSummary: function () {
            // this.ui.$summary_container.slideUp();
            this.$('[data-type="filter-breadcrumbs"]').slideUp();
        },

        params_for_resource: {
            courses: {},
            teachers: {},
            comments: {
                unlimited_comments: true
            }
        },

        initialize: function initialize () {
            _.bindAll(this, "showOrCreateTab", "hideLoader");

            this.filter_breadcrumbs = new FilteredSearch.Views.StructuresCollection.Filters.FilterBreadcrumbs.FilterBreadcrumbsView({
                template: StructureProfile.Views.Structure.templateDirname() + 'filter_breadcrumbs_view',
                fancy_breadcrumb_names: {
                    'address_name'        : 'Lieux',
                    'lat'                 : 'Lieux',
                    'lng'                 : 'Lieux',
                    'bbox_sw'             : 'Lieux',
                    'bbox_ne'             : 'Lieux',
                    'week_days'           : 'Date',
                    'audience_ids'        : 'Public',
                    'level_ids'           : 'Niveaux',
                    'min_age_for_kids'    : 'Audience',
                    'max_price'           : 'Prix',
                    'min_price'           : 'Prix',
                    'price_type'          : 'Prix',
                    'max_age_for_kids'    : 'Audience',
                    'trial_course_amount' : 'Cours d\'essai',
                    'course_types'        : 'Type de Cours',
                    'week_days'           : 'Date',
                    'discount_types'      : 'Tarifs réduits',
                    'start_date'          : 'Date',
                    'end_date'            : 'Date',
                    'start_hour'          : 'Date',
                    'end_hour'            : 'Date',
                }
            });

            // eaves drop on bootstraps tab implementation
            $(document).on("click", '[data-toggle=tab]', this.showOrCreateTab);

            this.empty_relation_handlers = {
                "courses": this.showEmptyCourses,
                "places" : this.showEmptyMap,
            };
        },

        onAfterShow: function onAfterShow () {
            this.showWidget(this.filter_breadcrumbs, {
                events: {
                    'filter:breadcrumbs:add'  :  'addBreadCrumbs',
                    'filter:breadcrumb:remove':  'removeBreadCrumb'
                }
            });

            this.trigger("filter:breadcrumbs:add", this.model.get("query_params"));
        },

        onRender: function onRender () {
            var $currently_active_tab = $(".tabs li.active"),
                anchor = $currently_active_tab.find("[data-toggle]");

            if (anchor.length > 0) {
                anchor = anchor[0];
                this.showOrCreateTab({ currentTarget: anchor });
            } else {
                this.showOrCreateTab({ currentTarget: $("[data-view=courses]")[0] });
            }
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

            // set the query_params on the model so that getparamsforresource will work
            this.model.set("query_params", params);

            this.updateModelWithRelation("courses").then(function () {
                this.ui.$summary_container.slideDown();
                this.summary_view.enableRemoveFilterButton();
            }.bind(this));

            this.updateModelWithRelation("places");
        },

        updateModelWithRelation: function updateModelWithRelation (relation) {
            var fetch = this.model.fetchRelated(relation, { data: this.getParamsForResource(relation)}, true)[0];

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
                .always(this.hideLoader);
        },

        renderCourseSummary: function renderCourseSummary (data) {
            this.summary_view.rerender(data);
        },

        showLoader: function(resources_name) {
            $('#tab-' + resources_name).append(this.ui.$loader);
            this.ui.$loader.show();
        },

        hideLoader: function() {
            this.ui.$loader.hide();
        },

        getParamsForResource: function getParamsForResource (resource) {
            return _.extend({}, this.params_for_resource[resource], this.model.get("query_params"));
        },

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
