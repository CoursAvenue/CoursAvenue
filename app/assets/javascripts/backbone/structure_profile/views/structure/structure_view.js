
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
            // 'filter:popstate'         : 'narrowSearch',
            'filter:removed'          : 'removeSummary'
        },

        removeSummary: function () {
            $('[data-type="filter-breadcrumbs"]').slideUp();
            this.broadenSearch();
        },

        initialize: function initialize () {
            _.bindAll(this, 'asyncLoadSection', 'hideLoader');

            this.summary_views = [];
            var $structure_profile_menu = $('#structure-profile-menu');
            $(window).scroll(function() {
                if ($(window).scrollTop() > 180 && parseInt($structure_profile_menu.css('top')) != 0 ) {
                    $structure_profile_menu.stop(true, false).animate({ 'top': '0' });
                } else if ($(window).scrollTop() < 180 && parseInt($structure_profile_menu.css('top')) == 0 ) {
                    $structure_profile_menu.stop(true, false).animate({ 'top': '-100px' });
                }
            });
            this.initializeContactLink();
        },

        initializeContactLink: function initializeContactLink () {
            $('body').on('click', '[data-behavior=show-contact-panel]', function() {
                var message_form_view = new StructureProfile.Views.Messages.MessageFormView( { structure: this.model } ).render();
                message_form_view.onAfterShow();
                $.magnificPopup.open({
                      items: {
                          src: $(message_form_view.$el),
                          type: 'inline'
                      }
                });
                return false;
            }.bind(this));
        },

        onAfterShow: function onAfterShow () {
            this.trigger("filter:breadcrumbs:add", this.model.get("query_params"));
        },

        onRender: function onRender () {
            this.asyncLoadSection('courses');
            this.asyncLoadSection('trainings');
            this.asyncLoadSection('teachers');
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

        asyncLoadSection: function asyncLoadSection (resource_name) {
            var ViewClass, view, model, fetch;

            ViewClass = this.findCollectionViewForResource(resource_name);

            // Only fetch when there is no data
            view = new ViewClass({
                collection : this.model.get(resource_name),
                data_url   : this.model.get("data_url"),
                about      : this.model.get('about'),
                about_genre: this.model.get('about_genre')
            });

            // always fetch, since we don't know whether we have resource_name or just ids
            this.showLoader(resource_name);
            this.updateModelWithRelation(resource_name)
                .then(function (collection) {
                    var summary_view;
                    if (resource_name === "courses") {
                        summary_view = new StructureProfile.Views.Structure.Courses.CoursesSummaryView(view.serializeData());
                        this.summary_views.push(summary_view);
                        this.showWidget(summary_view, { events: { 'courses:collection:reset': 'rerender' }});
                    } else if (resource_name === "trainings") {
                        summary_view = new StructureProfile.Views.Structure.Trainings.TrainingsSummaryView(view.serializeData());
                        this.summary_views.push(summary_view);
                        this.showWidget(summary_view, { events: { 'trainings:collection:reset': 'rerender' }});
                    }
                    this.showWidget(view);
                }.bind(this))
                .always(function() { this.hideLoader(resource_name) }.bind(this));
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
