
/* just a basic marionette view */
StructureProfile.module('Views.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = CoursAvenue.Views.EventLayout.extend({
        className: 'tabs-container',
        template: Module.templateDirname() + 'structure_view',

        ui: {
            '$loader'           : '[data-loader]',
            '$summary_container': '[data-summary-container]'
        },

        events: {
            'breadcrumbs:clear'       : 'broadenSearch',
            'filter:popstate'         : 'narrowSearch',
            'courses:collection:reset': 'renderCourseSummaries',
            'filter:removed'          : 'removeSummary',
            'click [data-toggle=tab] ': 'showOrCreateTab'
        },

        removeSummary: function () {
            $('[data-type="filter-breadcrumbs"]').slideUp();
            this.broadenSearch();
        },

        initialize: function initialize () {
            _.bindAll(this, "showOrCreateTab", "hideLoader");

            this.summary_views = [];

            // Initialize stickiness of header
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
                _.invoke(this.summary_views, 'enableRemoveFilterButton');
            }.bind(this));

            this.updateModelWithRelation("trainings");
            this.updateModelWithRelation("places");
        },

        /*
         * Fetch associated relation passing it the query_params
         */
        updateModelWithRelation: function updateModelWithRelation (relation) {
            var fetch = this.model.get(relation).fetch({ data: this.model.get("query_params") });

            if (fetch !== undefined) {
                fetch.then(function (response) {
                    this.model.get(relation).trigger('fetch:done', response);
                }.bind(this));
            }

            return fetch || new $.Deferred().reject();
        },

        showOrCreateTab: function showOrCreateTab (e) {
            var $target   = $(e.currentTarget),
                resources = $target.data("view"),
                ViewClass, view, model, fetch;

            // if this tab has no associated resource, or if it is already populated, we bail
            if (!resources) { return; }

            ViewClass = this.findCollectionViewForResource(resources);

            // Only fetch when there is no data
            view = new ViewClass({
                collection: this.model.get(resources),
                data_url: this.model.get("data_url")
            });

            // always fetch, since we don't know whether we have resources or just ids
            this.showLoader(resources);
            this.updateModelWithRelation(resources)
                .then(function (collection) {
                    var summary_view;
                    if (resources === "courses") {
                        summary_view = new StructureProfile.Views.Structure.Courses.CoursesSummaryView(view.serializeData());
                        this.summary_views.push(summary_view);
                        this.showWidget(summary_view, { events: { 'courses:collection:reset': 'rerender' }});
                    }

                    if (resources === "trainings") {
                        summary_view = new StructureProfile.Views.Structure.Trainings.TrainingsSummaryView(view.serializeData());
                        this.summary_views.push(summary_view);
                        this.showWidget(summary_view, { events: { 'courses:collection:reset': 'rerender' }});
                    }

                    this.showWidget(view);
                    $target.data("view", null); // remove the data-view property, indicating that no further fetching should be done

                }.bind(this))
                .always(function() { this.hideLoader(resources) }.bind(this));
        },

        serializeData: function serializeData () {
            var attributes = this.model.toJSON();
            attributes.description = this.hideContactsInfo(attributes.description);
            return attributes;
        },

        hideContactsInfo: function hideContactsInfo (text) {
            // Phone numbers
            text = text.replace(/((\+|00)33\s?|0)[1-5](\s?\d{2}){4}/g, '(numéro de téléphone)')
            // Links
            text = text.replace(/(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?/gi, '(site internet)')
            // Emails
            text = text.replace(/([^@\s]+)@(([-a-z0-9]+\.)+[a-z]{2,})/gi, '(e-mail de contact)');
            return text;
        },

        renderCourseSummaries: function renderCourseSummaries (data) {
            _.invoke(this.summary_views, 'rerender', data);
        },

        showLoader: function showLoader (resources_name) {
            $('#tab-' + resources_name).append(this.ui.$loader);
            this.$('[data-' + resources_name + '-loader]').show();
        },

        hideLoader: function hideLoader (resources_name) {
            this.$('[data-' + resources_name + '-loader]').hide();
        },

        /*
         * Return the collectionView related to the resource based on its name
         */
        findCollectionViewForResource: function findCollectionViewForResource (resources) {
            return Module[_.capitalize(resources)][_.capitalize(resources) + 'CollectionView'];
        }
    });
});
